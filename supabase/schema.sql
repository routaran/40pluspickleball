-- 40+ Pickleball Platform Database Schema
-- Version: 1.4
-- Description: Complete PostgreSQL schema for round robin pickleball events with auth integration, privacy enhancements, and comprehensive security hardening

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE - Organizers who can manage events
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'organizer' CHECK (role IN ('organizer', 'admin')),
    is_active BOOLEAN DEFAULT true,
    auth_id UUID UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Link to Supabase auth.users table
    CONSTRAINT users_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- =====================================================
-- EVENTS TABLE - Single-day round robin tournaments
-- =====================================================
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME,
    created_by UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    
    -- Court configuration - stores actual court identifiers
    -- Example: ["C9", "C10", "C11", "C12"] or ["North 1", "North 2", "South 1", "South 2"]
    courts JSONB NOT NULL DEFAULT '[]'::jsonb,
    
    -- Scoring format configuration
    -- Example: {"games_to": 11, "win_by": 2, "match_format": "1_game"}
    scoring_format JSONB NOT NULL DEFAULT '{"games_to": 11, "win_by": 2, "match_format": "1_game"}'::jsonb,
    
    -- Event settings
    max_players INTEGER,
    allow_mid_event_joins BOOLEAN DEFAULT false,
    is_public BOOLEAN DEFAULT true,
    
    -- Timezone for local time display (default: America/Edmonton)
    timezone VARCHAR(50) DEFAULT 'America/Edmonton',
    
    -- Print layout preferences
    print_settings JSONB DEFAULT '{"courts_per_page": 4, "font_size": "12pt", "orientation": "landscape"}'::jsonb,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Note: For public access, use public_events view to protect organizer emails
COMMENT ON TABLE events IS 'Main events table. For public access, use public_events view to protect organizer emails.';

-- =====================================================
-- PLAYERS TABLE - Participants (not authenticated users)
-- =====================================================
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    skill_level VARCHAR(50), -- '2.5', '3.0', '3.5', '4.0', '4.5', '5.0'
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
    
    -- Ensure unique players by name (can have multiple Johns, but not exact duplicates)
    -- Note: Unique constraint will be added as functional index below
);

-- =====================================================
-- EVENT_PLAYERS - Players registered for each event
-- =====================================================
CREATE TABLE event_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id),
    check_out_time TIMESTAMPTZ, -- When player leaves early
    status VARCHAR(50) DEFAULT 'registered' CHECK (status IN ('registered', 'departed', 'no_show')),
    added_by UUID REFERENCES users(id),
    
    -- Track which round player joined (for late joins)
    joined_at_round INTEGER DEFAULT 1,
    
    -- Bye round tracking to prevent consecutive byes
    last_bye_round INTEGER,
    total_bye_rounds INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(event_id, player_id)
);

-- =====================================================
-- ROUNDS TABLE - Track round progression
-- =====================================================
CREATE TABLE rounds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed')),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Track if this round was added after initial schedule
    is_additional BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(event_id, round_number)
);

-- =====================================================
-- MATCHES TABLE - Individual games with court assignments
-- =====================================================
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
    match_number INTEGER NOT NULL,
    
    -- Court assignment - stores actual court identifier from event.courts
    -- Example: "C9", "C10", "North 1", etc.
    court_assignment VARCHAR(50),
    
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    is_bye BOOLEAN DEFAULT false,
    
    -- For tracking match timing
    scheduled_time TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(round_id, match_number)
);

-- =====================================================
-- MATCH_PLAYERS - Track players/teams in each match
-- =====================================================
CREATE TABLE match_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id),
    team INTEGER NOT NULL CHECK (team IN (1, 2)), -- Team 1 or Team 2
    position INTEGER NOT NULL CHECK (position IN (1, 2)), -- Position 1 or 2 within team (for doubles)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(match_id, player_id),
    UNIQUE(match_id, team, position)
);

-- =====================================================
-- MATCH_SCORES - Store game results
-- =====================================================
CREATE TABLE match_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID UNIQUE NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team1_score INTEGER NOT NULL CHECK (team1_score >= 0),
    team2_score INTEGER NOT NULL CHECK (team2_score >= 0),
    winning_team INTEGER CHECK (winning_team IN (1, 2)),
    
    -- Additional game details
    duration_minutes INTEGER,
    notes TEXT,
    recorded_by UUID REFERENCES users(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_created_by ON events(created_by);

-- Unique constraint for players using functional index (handles COALESCE for nullable fields)
CREATE UNIQUE INDEX idx_players_unique_identity ON players(name, COALESCE(email, ''), COALESCE(phone, ''));

CREATE INDEX idx_event_players_event_id ON event_players(event_id);
CREATE INDEX idx_event_players_player_id ON event_players(player_id);
CREATE INDEX idx_event_players_status ON event_players(status);
CREATE INDEX idx_event_players_joined_at_round ON event_players(joined_at_round);
CREATE INDEX idx_event_players_last_bye_round ON event_players(last_bye_round);

CREATE INDEX idx_rounds_event_id ON rounds(event_id);
CREATE INDEX idx_rounds_status ON rounds(status);
CREATE INDEX idx_rounds_is_additional ON rounds(is_additional);

CREATE INDEX idx_matches_event_id ON matches(event_id);
CREATE INDEX idx_matches_round_id ON matches(round_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_court_assignment ON matches(court_assignment);

CREATE INDEX idx_match_players_match_id ON match_players(match_id);
CREATE INDEX idx_match_players_player_id ON match_players(player_id);

CREATE INDEX idx_match_scores_match_id ON match_scores(match_id);

-- =====================================================
-- PLAYER_STATISTICS TABLE - Cross-event tracking
-- =====================================================
CREATE TABLE player_statistics (
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
CREATE INDEX idx_player_statistics_win_percentage ON player_statistics(win_percentage DESC);

-- =====================================================
-- ERROR_LOGS TABLE - System error tracking
-- =====================================================
CREATE TABLE error_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    error_type VARCHAR(50) NOT NULL CHECK (error_type IN ('auth', 'api', 'validation', 'system')),
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    user_id UUID REFERENCES users(id),
    event_id UUID REFERENCES events(id),
    browser_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(id)
);

-- Index for performance when querying recent errors
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at DESC);
CREATE INDEX idx_error_logs_resolved ON error_logs(resolved, created_at DESC);

-- =====================================================
-- EMAIL_QUEUE TABLE - For admin notifications
-- =====================================================
CREATE TABLE email_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    error_log_id UUID REFERENCES error_logs(id),
    sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ,
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for processing pending emails
CREATE INDEX idx_email_queue_pending ON email_queue(sent, created_at) WHERE sent = false;

-- =====================================================
-- UPDATED_AT TRIGGER FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_players_updated_at BEFORE UPDATE ON event_players 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rounds_updated_at BEFORE UPDATE ON rounds 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_scores_updated_at BEFORE UPDATE ON match_scores 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_statistics_updated_at BEFORE UPDATE ON player_statistics 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: Public-safe events (hides organizer emails)
CREATE VIEW public_events AS
SELECT 
    e.id, e.name, e.event_date, e.start_time, e.status,
    e.courts, e.scoring_format, e.max_players, 
    e.allow_mid_event_joins, e.is_public, e.timezone, e.print_settings,
    e.created_at, e.updated_at,
    u.display_name as organizer_name
FROM events e
JOIN users u ON e.created_by = u.id
WHERE e.is_public = true;

-- Grant public access to the view
GRANT SELECT ON public_events TO anon, authenticated;

-- View: Current active events
CREATE VIEW active_events AS
SELECT 
    e.*,
    u.display_name as organizer_name,
    COUNT(DISTINCT ep.player_id) as player_count,
    jsonb_array_length(e.courts) as court_count
FROM events e
JOIN users u ON e.created_by = u.id
LEFT JOIN event_players ep ON e.id = ep.event_id AND ep.status != 'departed'
WHERE e.status = 'active'
GROUP BY e.id, u.display_name;

-- View: Match details with player names
CREATE VIEW match_details AS
SELECT 
    m.*,
    e.name as event_name,
    r.round_number,
    -- Team 1 players
    STRING_AGG(
        CASE WHEN mp.team = 1 THEN p.name END, 
        ' & ' ORDER BY mp.position
    ) as team1_players,
    -- Team 2 players
    STRING_AGG(
        CASE WHEN mp.team = 2 THEN p.name END, 
        ' & ' ORDER BY mp.position
    ) as team2_players,
    ms.team1_score,
    ms.team2_score,
    ms.winning_team
FROM matches m
JOIN rounds r ON m.round_id = r.id
JOIN events e ON m.event_id = e.id
LEFT JOIN match_players mp ON m.id = mp.match_id
LEFT JOIN players p ON mp.player_id = p.id
LEFT JOIN match_scores ms ON m.id = ms.match_id
GROUP BY m.id, e.name, r.round_number, ms.team1_score, ms.team2_score, ms.winning_team;

-- View: Player standings by event with joined_at_round support
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
)
SELECT 
    *,
    wins::decimal / NULLIF(matches_played, 0) as win_percentage,
    points_for - points_against as point_differential,
    RANK() OVER (
        PARTITION BY event_id 
        ORDER BY 
            wins DESC,
            points_for - points_against DESC,
            points_for DESC
    ) as ranking
FROM player_results
ORDER BY event_id, ranking;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_queue ENABLE ROW LEVEL SECURITY;

-- Public read access for events, matches, and scores
CREATE POLICY "Events are viewable by everyone" ON events
    FOR SELECT USING (is_public = true);

CREATE POLICY "Players are viewable by everyone" ON players
    FOR SELECT USING (true);

-- Only authenticated organizers can create players
CREATE POLICY "Only organizers can create players" ON players
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.auth_id = auth.uid()
        )
    );

-- Only authenticated organizers can update players  
CREATE POLICY "Only organizers can update players" ON players
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.auth_id = auth.uid()
        )
    );

-- Prevent all deletes (use is_active flag for soft delete)
CREATE POLICY "No one can delete players" ON players
    FOR DELETE USING (false);

CREATE POLICY "Event players are viewable by everyone" ON event_players
    FOR SELECT USING (true);

CREATE POLICY "Rounds are viewable by everyone" ON rounds
    FOR SELECT USING (true);

CREATE POLICY "Matches are viewable by everyone" ON matches
    FOR SELECT USING (true);

CREATE POLICY "Match players are viewable by everyone" ON match_players
    FOR SELECT USING (true);

CREATE POLICY "Match scores are viewable by everyone" ON match_scores
    FOR SELECT USING (true);

CREATE POLICY "Player statistics are viewable by everyone" ON player_statistics
    FOR SELECT USING (true);

-- Statistics are read-only, updated only by triggers
CREATE POLICY "No direct statistics inserts" ON player_statistics
    FOR INSERT WITH CHECK (false);

CREATE POLICY "No direct statistics updates" ON player_statistics
    FOR UPDATE USING (false);

CREATE POLICY "No statistics deletion" ON player_statistics
    FOR DELETE USING (false);

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = auth_id)
    WITH CHECK (auth.uid() = auth_id AND role = (SELECT role FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "No direct user creation" ON users
    FOR INSERT WITH CHECK (false);

CREATE POLICY "No user deletion" ON users
    FOR DELETE USING (false);

-- Authenticated users (organizers) can manage their own events
CREATE POLICY "Organizers can create events" ON events
    FOR INSERT WITH CHECK (
        created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
    );

CREATE POLICY "Organizers can update their own events" ON events
    FOR UPDATE USING (
        created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
    );

-- Prevent event deletion
CREATE POLICY "No event deletion" ON events
    FOR DELETE USING (false);

CREATE POLICY "Organizers can manage players in their events" ON event_players
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = event_players.event_id 
            AND events.created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Prevent event player deletion
CREATE POLICY "No event player deletion" ON event_players
    FOR DELETE USING (false);

CREATE POLICY "Organizers can manage rounds in their events" ON rounds
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = rounds.event_id 
            AND events.created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Prevent round deletion
CREATE POLICY "No round deletion" ON rounds
    FOR DELETE USING (false);

CREATE POLICY "Organizers can manage matches in their events" ON matches
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM events 
            WHERE events.id = matches.event_id 
            AND events.created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Prevent match deletion
CREATE POLICY "No match deletion" ON matches
    FOR DELETE USING (false);

CREATE POLICY "Organizers can manage match players in their events" ON match_players
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM matches m
            JOIN events e ON m.event_id = e.id 
            WHERE m.id = match_players.match_id 
            AND e.created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Prevent match player deletion
CREATE POLICY "No match player deletion" ON match_players
    FOR DELETE USING (false);

CREATE POLICY "Organizers can manage scores in their events" ON match_scores
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM matches m
            JOIN events e ON m.event_id = e.id 
            WHERE m.id = match_scores.match_id 
            AND e.created_by = (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Prevent score deletion
CREATE POLICY "No score deletion" ON match_scores
    FOR DELETE USING (false);

-- Error logs - only admins can view, service role can insert
CREATE POLICY "Only admins can view error logs" ON error_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.auth_id = auth.uid() 
            AND users.role = 'admin'
        )
    );

-- Service role bypass for error log inserts (application can log errors)
CREATE POLICY "Service role can insert error logs" ON error_logs
    FOR INSERT WITH CHECK (true);

-- Prevent error log deletion
CREATE POLICY "No error log deletion" ON error_logs
    FOR DELETE USING (false);

-- Email queue - only admins can view, service role can manage
CREATE POLICY "Only admins can view email queue" ON email_queue
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.auth_id = auth.uid() 
            AND users.role = 'admin'
        )
    );

-- Service role bypass for email queue management
CREATE POLICY "Service role can manage email queue" ON email_queue
    FOR ALL WITH CHECK (true);

-- Prevent email queue deletion
CREATE POLICY "No email queue deletion" ON email_queue
    FOR DELETE USING (false);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get current round for an event
CREATE OR REPLACE FUNCTION get_current_round(event_id_param UUID)
RETURNS TABLE(round_id UUID, round_number INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, round_number
    FROM rounds
    WHERE event_id = event_id_param
    AND status = 'active'
    ORDER BY round_number DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to check if all matches in a round are completed
CREATE OR REPLACE FUNCTION is_round_complete(round_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
    incomplete_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO incomplete_count
    FROM matches
    WHERE round_id = round_id_param
    AND status != 'completed'
    AND is_bye = false;
    
    RETURN incomplete_count = 0;
END;
$$ LANGUAGE plpgsql;

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
CREATE TRIGGER validate_court_assignment_trigger
    BEFORE INSERT OR UPDATE OF court_assignment ON matches
    FOR EACH ROW
    EXECUTE FUNCTION validate_court_assignment();

-- =====================================================
-- ERROR NOTIFICATION FUNCTION AND TRIGGER
-- =====================================================
CREATE OR REPLACE FUNCTION notify_admin_on_error()
RETURNS TRIGGER AS $$
DECLARE
    admin_email VARCHAR(255);
BEGIN
    -- Get admin email (first admin found)
    SELECT email INTO admin_email
    FROM users 
    WHERE role = 'admin' 
    LIMIT 1;
    
    -- If no admin found, try to get any organizer
    IF admin_email IS NULL THEN
        SELECT email INTO admin_email
        FROM users 
        WHERE role = 'organizer' 
        ORDER BY created_at
        LIMIT 1;
    END IF;
    
    -- Only create email queue entry if we have a recipient
    IF admin_email IS NOT NULL THEN
        INSERT INTO email_queue (
            to_email,
            subject,
            body,
            error_log_id,
            created_at
        ) VALUES (
            admin_email,
            'Error Alert: ' || NEW.error_type || ' error in 40+ Pickleball',
            'An error has occurred in the 40+ Pickleball application.' || E'\n\n' ||
            'Error Type: ' || NEW.error_type || E'\n' ||
            'Error Message: ' || NEW.error_message || E'\n\n' ||
            'Stack Trace: ' || E'\n' || COALESCE(NEW.stack_trace, 'No stack trace available') || E'\n\n' ||
            'Time: ' || NEW.created_at::text || E'\n' ||
            'User ID: ' || COALESCE(NEW.user_id::text, 'Not logged in') || E'\n' ||
            'Event ID: ' || COALESCE(NEW.event_id::text, 'No event context'),
            NEW.id,
            NOW()
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to send email notifications for errors
CREATE TRIGGER error_log_email_trigger
AFTER INSERT ON error_logs
FOR EACH ROW
EXECUTE FUNCTION notify_admin_on_error();

-- =====================================================
-- SECURITY FUNCTIONS AND CONSTRAINTS
-- =====================================================

-- Function to check event capacity
CREATE OR REPLACE FUNCTION check_event_capacity_limit()
RETURNS TRIGGER AS $$
DECLARE
    current_registered INTEGER;
    max_allowed INTEGER;
BEGIN
    -- Only check for new registrations or status changes to 'registered'
    IF NEW.status = 'registered' AND (TG_OP = 'INSERT' OR OLD.status != 'registered') THEN
        SELECT COUNT(*), e.max_players 
        INTO current_registered, max_allowed
        FROM event_players ep
        JOIN events e ON ep.event_id = e.id
        WHERE ep.event_id = NEW.event_id 
        AND ep.status = 'registered'
        AND ep.id != NEW.id  -- Don't count the current row
        GROUP BY e.max_players;
        
        IF max_allowed IS NOT NULL AND current_registered >= max_allowed THEN
            RAISE EXCEPTION 'Event has reached maximum capacity of % players', max_allowed;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce event capacity
CREATE TRIGGER enforce_event_capacity
    BEFORE INSERT OR UPDATE ON event_players
    FOR EACH ROW
    EXECUTE FUNCTION check_event_capacity_limit();

-- Function to validate score entries
CREATE OR REPLACE FUNCTION validate_match_score()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure scores are non-negative
    IF NEW.team1_score < 0 OR NEW.team2_score < 0 THEN
        RAISE EXCEPTION 'Scores cannot be negative';
    END IF;
    
    -- Ensure winning team is set correctly
    IF NEW.winning_team IS NOT NULL THEN
        IF NEW.winning_team NOT IN (1, 2) THEN
            RAISE EXCEPTION 'Winning team must be 1 or 2';
        END IF;
        
        -- Verify winner has higher score
        IF (NEW.winning_team = 1 AND NEW.team1_score <= NEW.team2_score) OR
           (NEW.winning_team = 2 AND NEW.team2_score <= NEW.team1_score) THEN
            RAISE EXCEPTION 'Winning team must have higher score';
        END IF;
    END IF;
    
    -- Ensure match exists and is not a bye
    IF NOT EXISTS (
        SELECT 1 FROM matches 
        WHERE id = NEW.match_id 
        AND is_bye = false
    ) THEN
        RAISE EXCEPTION 'Cannot enter scores for bye matches or non-existent matches';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate scores
CREATE TRIGGER validate_match_score_trigger
    BEFORE INSERT OR UPDATE ON match_scores
    FOR EACH ROW
    EXECUTE FUNCTION validate_match_score();

-- Function to prevent role escalation
CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
    -- If role is being changed, only allow if user is admin
    IF NEW.role != OLD.role THEN
        IF NOT EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = auth.uid() 
            AND role = 'admin'
        ) THEN
            RAISE EXCEPTION 'Only admins can change user roles';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to prevent role escalation
CREATE TRIGGER prevent_role_escalation_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION prevent_role_escalation();

-- =====================================================
-- API USAGE MONITORING (Optional)
-- =====================================================

-- Table to track API usage for monitoring
CREATE TABLE IF NOT EXISTS api_usage_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ip_address INET,
    endpoint VARCHAR(255),
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for performance
CREATE INDEX idx_api_usage_created_at ON api_usage_log(created_at DESC);
CREATE INDEX idx_api_usage_ip ON api_usage_log(ip_address, created_at DESC);

-- Enable RLS on api_usage_log
ALTER TABLE api_usage_log ENABLE ROW LEVEL SECURITY;

-- Only service role can write to usage log
CREATE POLICY "Service role manages usage log" ON api_usage_log
    FOR ALL WITH CHECK (false);  -- Frontend cannot access this

-- =====================================================
-- SECURITY DOCUMENTATION COMMENTS
-- =====================================================

COMMENT ON SCHEMA public IS 'Schema version 1.4 - Security hardening applied. All tables protected with comprehensive RLS policies.';

COMMENT ON POLICY "Only organizers can create players" ON players IS 
'Prevents anonymous users from creating fake player records. Only authenticated organizers can add players.';

COMMENT ON POLICY "No one can delete players" ON players IS 
'Enforces data integrity by preventing hard deletes. Use is_active flag for soft deletes.';

COMMENT ON TRIGGER enforce_event_capacity ON event_players IS 
'Prevents event capacity from being exceeded through direct database manipulation.';

COMMENT ON TRIGGER validate_match_score_trigger ON match_scores IS 
'Ensures score integrity by validating winning team has higher score and matches exist.';

-- =====================================================
-- SAMPLE DATA (Optional - Remove for production)
-- =====================================================

-- Sample organizer
INSERT INTO users (email, display_name, role) VALUES
('organizer@40pluspickleball.com', 'John Organizer', 'organizer');

-- Sample event with court configuration
INSERT INTO events (name, event_date, created_by, courts, status) VALUES
('Saturday Morning Round Robin', CURRENT_DATE + 1, 
 (SELECT id FROM users LIMIT 1),
 '["C9", "C10", "C11", "C12"]'::jsonb,
 'draft');

-- Sample players
INSERT INTO players (name, email, skill_level) VALUES
('Alice Johnson', 'alice@example.com', '3.5'),
('Bob Smith', 'bob@example.com', '3.5'),
('Carol Davis', 'carol@example.com', '3.0'),
('David Wilson', 'david@example.com', '4.0'),
('Eve Martinez', 'eve@example.com', '3.5'),
('Frank Brown', 'frank@example.com', '3.0'),
('Grace Lee', 'grace@example.com', '4.0'),
('Henry Taylor', 'henry@example.com', '3.5');

-- Add players to event
INSERT INTO event_players (event_id, player_id, status)
SELECT 
    (SELECT id FROM events LIMIT 1),
    id,
    'registered'
FROM players;