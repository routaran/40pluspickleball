-- Migration: PRD Alignment Updates for 40+ Pickleball Platform
-- Version: 1.1
-- Description: Updates to align database schema with Product Requirements Document
-- Date: 2025-01-21

-- =====================================================
-- CORE SCHEMA UPDATES
-- =====================================================

-- 1. Add timezone support to events (default: America/Edmonton as requested)
ALTER TABLE events ADD COLUMN IF NOT EXISTS timezone VARCHAR(50) DEFAULT 'America/Edmonton';
COMMENT ON COLUMN events.timezone IS 'Timezone for displaying event times locally';

-- 2. Track bye rounds to prevent consecutive byes
ALTER TABLE event_players ADD COLUMN IF NOT EXISTS last_bye_round INTEGER;
ALTER TABLE event_players ADD COLUMN IF NOT EXISTS total_bye_rounds INTEGER DEFAULT 0;
COMMENT ON COLUMN event_players.last_bye_round IS 'Last round number where player had a bye';
COMMENT ON COLUMN event_players.total_bye_rounds IS 'Total number of bye rounds for fairness tracking';

-- 3. Track which round a player joined (for late joins)
ALTER TABLE event_players ADD COLUMN IF NOT EXISTS joined_at_round INTEGER DEFAULT 1;
COMMENT ON COLUMN event_players.joined_at_round IS 'Round number when player joined the event (1 = from start)';

-- 4. Distinguish between scheduled and additional rounds
ALTER TABLE rounds ADD COLUMN IF NOT EXISTS is_additional BOOLEAN DEFAULT false;
COMMENT ON COLUMN rounds.is_additional IS 'True if round was added after initial schedule';

-- 5. Store print layout preferences
ALTER TABLE events ADD COLUMN IF NOT EXISTS print_settings JSONB DEFAULT '{"courts_per_page": 4, "font_size": "12pt", "orientation": "landscape"}'::jsonb;
COMMENT ON COLUMN events.print_settings IS 'Printing preferences for schedules and standings';

-- 6. Remove unnecessary check_in_time since events don't start until all players are present
ALTER TABLE event_players DROP COLUMN IF EXISTS check_in_time;

-- =====================================================
-- HEAD-TO-HEAD TIEBREAKER FUNCTION
-- =====================================================

-- Function to determine head-to-head winner between two players
CREATE OR REPLACE FUNCTION get_head_to_head_winner(
    player1_id UUID, 
    player2_id UUID, 
    event_id_param UUID
) RETURNS INTEGER AS $$
DECLARE
    p1_wins INTEGER := 0;
    p2_wins INTEGER := 0;
BEGIN
    -- Count wins when players faced each other
    SELECT 
        COUNT(CASE WHEN mp1.team = ms.winning_team THEN 1 END),
        COUNT(CASE WHEN mp2.team = ms.winning_team THEN 1 END)
    INTO p1_wins, p2_wins
    FROM matches m
    JOIN match_players mp1 ON m.id = mp1.match_id AND mp1.player_id = player1_id
    JOIN match_players mp2 ON m.id = mp2.match_id AND mp2.player_id = player2_id
    JOIN match_scores ms ON m.id = ms.match_id
    WHERE m.event_id = event_id_param
    AND mp1.team != mp2.team;  -- They were opponents
    
    -- Return: 1 if player1 wins H2H, 2 if player2 wins, 0 if tied
    IF p1_wins > p2_wins THEN
        RETURN 1;
    ELSIF p2_wins > p1_wins THEN
        RETURN 2;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- ENHANCED PLAYER STANDINGS VIEW
-- =====================================================

-- Drop existing view to recreate with proper tiebreaker logic
DROP VIEW IF EXISTS player_standings;

-- Create enhanced view with complete tiebreaker implementation
CREATE VIEW player_standings AS
WITH player_results AS (
    SELECT 
        ep.event_id,
        ep.player_id,
        p.name as player_name,
        ep.joined_at_round,
        -- Only count matches from rounds >= when they joined
        COUNT(DISTINCT CASE 
            WHEN r.round_number >= ep.joined_at_round THEN m.id 
        END) as matches_played,
        COUNT(DISTINCT CASE 
            WHEN r.round_number >= ep.joined_at_round AND mp.team = ms.winning_team 
            THEN m.id 
        END) as wins,
        COUNT(DISTINCT CASE 
            WHEN r.round_number >= ep.joined_at_round AND mp.team != ms.winning_team AND ms.winning_team IS NOT NULL 
            THEN m.id 
        END) as losses,
        COALESCE(SUM(CASE 
            WHEN r.round_number >= ep.joined_at_round THEN
                CASE 
                    WHEN mp.team = 1 THEN ms.team1_score 
                    WHEN mp.team = 2 THEN ms.team2_score 
                END
        END), 0) as points_for,
        COALESCE(SUM(CASE 
            WHEN r.round_number >= ep.joined_at_round THEN
                CASE 
                    WHEN mp.team = 1 THEN ms.team2_score 
                    WHEN mp.team = 2 THEN ms.team1_score 
                END
        END), 0) as points_against
    FROM event_players ep
    JOIN players p ON ep.player_id = p.id
    LEFT JOIN match_players mp ON mp.player_id = ep.player_id
    LEFT JOIN matches m ON mp.match_id = m.id AND m.event_id = ep.event_id
    LEFT JOIN rounds r ON m.round_id = r.id
    LEFT JOIN match_scores ms ON m.id = ms.match_id
    WHERE ep.status != 'departed'
    GROUP BY ep.event_id, ep.player_id, p.name, ep.joined_at_round
),
ranked_results AS (
    SELECT 
        pr.*,
        wins::decimal / NULLIF(matches_played, 0) as win_percentage,
        points_for - points_against as point_differential,
        -- Create a tiebreaker score for sorting
        -- Format: WWWW.HHHH.DDDDDDDD.PPPPPPPP
        -- W = wins (padded to 4 digits)
        -- H = head-to-head (will be calculated separately)
        -- D = point differential + 10000 (to handle negatives)
        -- P = points for
        LPAD(wins::text, 4, '0') || '.0000.' || 
        LPAD(((points_for - points_against) + 10000)::text, 8, '0') || '.' ||
        LPAD(points_for::text, 8, '0') as tiebreaker_score
    FROM player_results pr
)
SELECT 
    *,
    RANK() OVER (
        PARTITION BY event_id 
        ORDER BY tiebreaker_score DESC
    ) as ranking
FROM ranked_results
ORDER BY event_id, ranking;

-- Note: For true head-to-head tiebreaking in the application layer,
-- call get_head_to_head_winner() for players with identical wins

-- =====================================================
-- PLAYER STATISTICS TABLE (Cross-Event Tracking)
-- =====================================================

CREATE TABLE IF NOT EXISTS player_statistics (
    player_id UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
    total_events INTEGER DEFAULT 0,
    total_matches INTEGER DEFAULT 0,
    total_wins INTEGER DEFAULT 0,
    total_losses INTEGER DEFAULT 0,
    total_points_for INTEGER DEFAULT 0,
    total_points_against INTEGER DEFAULT 0,
    win_percentage DECIMAL(5,4) GENERATED ALWAYS AS (
        CASE 
            WHEN total_matches > 0 THEN total_wins::decimal / total_matches 
            ELSE 0 
        END
    ) STORED,
    avg_point_differential DECIMAL(6,2) GENERATED ALWAYS AS (
        CASE 
            WHEN total_matches > 0 THEN (total_points_for - total_points_against)::decimal / total_matches 
            ELSE 0 
        END
    ) STORED,
    last_event_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_player_statistics_win_percentage ON player_statistics(win_percentage DESC);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to automatically calculate match duration
CREATE OR REPLACE FUNCTION calculate_match_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.completed_at IS NOT NULL AND OLD.started_at IS NOT NULL THEN
        UPDATE match_scores 
        SET duration_minutes = EXTRACT(EPOCH FROM (NEW.completed_at - OLD.started_at)) / 60
        WHERE match_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate duration when match is completed
DROP TRIGGER IF EXISTS calculate_match_duration_trigger ON matches;
CREATE TRIGGER calculate_match_duration_trigger
    AFTER UPDATE OF completed_at ON matches
    FOR EACH ROW
    WHEN (NEW.completed_at IS NOT NULL)
    EXECUTE FUNCTION calculate_match_duration();

-- Function to validate court assignments
CREATE OR REPLACE FUNCTION validate_court_assignment()
RETURNS TRIGGER AS $$
DECLARE
    valid_courts JSONB;
BEGIN
    -- Get valid courts for this event
    SELECT courts INTO valid_courts
    FROM events
    WHERE id = NEW.event_id;
    
    -- Check if assigned court exists in event's court list
    IF NEW.court_assignment IS NOT NULL AND 
       NOT (valid_courts ? NEW.court_assignment OR 
            valid_courts @> to_jsonb(NEW.court_assignment)) THEN
        RAISE EXCEPTION 'Invalid court assignment: % is not in event courts', NEW.court_assignment;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate court assignments
DROP TRIGGER IF EXISTS validate_court_assignment_trigger ON matches;
CREATE TRIGGER validate_court_assignment_trigger
    BEFORE INSERT OR UPDATE OF court_assignment ON matches
    FOR EACH ROW
    EXECUTE FUNCTION validate_court_assignment();

-- =====================================================
-- UPDATE INDEXES FOR NEW COLUMNS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_event_players_joined_at_round ON event_players(joined_at_round);
CREATE INDEX IF NOT EXISTS idx_event_players_last_bye_round ON event_players(last_bye_round);
CREATE INDEX IF NOT EXISTS idx_rounds_is_additional ON rounds(is_additional);

-- =====================================================
-- UPDATE RLS POLICIES FOR NEW TABLES
-- =====================================================

-- Enable RLS on player_statistics
ALTER TABLE player_statistics ENABLE ROW LEVEL SECURITY;

-- Public read access for player statistics
CREATE POLICY "Player statistics are viewable by everyone" ON player_statistics
    FOR SELECT USING (true);

-- Only system can update statistics (through triggers/functions)
-- No direct user updates allowed

-- =====================================================
-- UPDATE TRIGGERS FOR NEW TABLES
-- =====================================================

CREATE TRIGGER update_player_statistics_updated_at 
    BEFORE UPDATE ON player_statistics 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- MIGRATION COMPLETION
-- =====================================================

-- Add migration tracking comment
COMMENT ON SCHEMA public IS 'Schema version 1.1 - PRD alignment updates applied';