-- Migration: Auth Integration and Privacy Enhancements
-- Version: 1.2 to 1.3
-- Description: Adds Supabase auth integration and privacy improvements

-- =====================================================
-- 1. Fix naming to match PRD terminology
-- =====================================================
ALTER TABLE events RENAME COLUMN allow_late_joins TO allow_mid_event_joins;

-- =====================================================
-- 2. Add Supabase auth integration to users table
-- =====================================================
-- Add auth_id column to link with Supabase auth.users
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_id UUID UNIQUE;

-- Add foreign key constraint to auth.users
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_auth_id_fkey;
ALTER TABLE users ADD CONSTRAINT users_auth_id_fkey 
FOREIGN KEY (auth_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- =====================================================
-- 3. Create privacy-conscious public view
-- =====================================================
-- Drop view if exists (for re-running migration)
DROP VIEW IF EXISTS public_events;

-- Create view that hides organizer emails
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

-- =====================================================
-- 4. Add helpful comments
-- =====================================================
COMMENT ON TABLE events IS 'Main events table. For public access, use public_events view to protect organizer emails.';
COMMENT ON COLUMN users.auth_id IS 'Links to Supabase auth.users table for authentication';
COMMENT ON VIEW public_events IS 'Public-safe view of events that excludes organizer email addresses';

-- =====================================================
-- MIGRATION NOTES
-- =====================================================
-- This migration:
-- 1. Aligns field naming with PRD (allow_mid_event_joins)
-- 2. Integrates with Supabase Auth for magic link authentication
-- 3. Protects organizer privacy by creating a public-safe view
--
-- After running this migration:
-- 1. Configure Supabase Auth for magic link authentication
-- 2. Update application queries to use public_events view for unauthenticated users
-- 3. Ensure new user registrations create both auth.users and public.users records