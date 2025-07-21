-- Migration: Security Hardening for 40+ Pickleball Platform
-- Version: 1.4
-- Description: Comprehensive security policies to protect against anon key exploitation
-- Date: 2025-01-21

-- =====================================================
-- PLAYERS TABLE SECURITY POLICIES
-- =====================================================

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

-- =====================================================
-- USERS TABLE SECURITY POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = auth_id);

-- Users can update their own profile (but not their role)
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = auth_id)
    WITH CHECK (auth.uid() = auth_id AND role = (SELECT role FROM users WHERE auth_id = auth.uid()));

-- Only through auth.users trigger can create users
CREATE POLICY "No direct user creation" ON users
    FOR INSERT WITH CHECK (false);

-- Prevent user deletion
CREATE POLICY "No user deletion" ON users
    FOR DELETE USING (false);

-- =====================================================
-- PLAYER STATISTICS PROTECTION
-- =====================================================

-- Statistics are read-only, updated only by triggers
CREATE POLICY "No direct statistics inserts" ON player_statistics
    FOR INSERT WITH CHECK (false);

CREATE POLICY "No direct statistics updates" ON player_statistics
    FOR UPDATE USING (false);

CREATE POLICY "No statistics deletion" ON player_statistics
    FOR DELETE USING (false);

-- =====================================================
-- COMPREHENSIVE DELETE PREVENTION
-- =====================================================

-- Events: Only allow soft delete via status change to 'cancelled'
CREATE POLICY "No event deletion" ON events
    FOR DELETE USING (false);

-- Event Players: Prevent deletion, use status changes instead
CREATE POLICY "No event player deletion" ON event_players
    FOR DELETE USING (false);

-- Rounds: Prevent deletion to maintain history
CREATE POLICY "No round deletion" ON rounds
    FOR DELETE USING (false);

-- Matches: Prevent deletion to maintain history
CREATE POLICY "No match deletion" ON matches
    FOR DELETE USING (false);

-- Match Players: Prevent deletion
CREATE POLICY "No match player deletion" ON match_players
    FOR DELETE USING (false);

-- Match Scores: Prevent deletion to maintain integrity
CREATE POLICY "No score deletion" ON match_scores
    FOR DELETE USING (false);

-- Error logs: Already protected, ensure no deletion
CREATE POLICY "No error log deletion" ON error_logs
    FOR DELETE USING (false);

-- Email queue: Prevent deletion
CREATE POLICY "No email queue deletion" ON email_queue
    FOR DELETE USING (false);

-- =====================================================
-- DATABASE-LEVEL CONSTRAINTS
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

-- =====================================================
-- ADDITIONAL SECURITY FUNCTIONS
-- =====================================================

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
-- RATE LIMITING HELPER
-- =====================================================

-- Table to track API usage (optional, for monitoring)
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
-- SECURITY DOCUMENTATION
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
-- MIGRATION COMPLETION
-- =====================================================

-- Verify all tables have RLS enabled and appropriate policies
DO $$
DECLARE
    tbl RECORD;
    policy_count INTEGER;
BEGIN
    FOR tbl IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT IN ('api_usage_log')  -- Exclude monitoring table
    LOOP
        SELECT COUNT(*) INTO policy_count
        FROM pg_policies
        WHERE schemaname = 'public' AND tablename = tbl.tablename;
        
        IF policy_count = 0 THEN
            RAISE WARNING 'Table % has no RLS policies defined!', tbl.tablename;
        END IF;
    END LOOP;
END $$;