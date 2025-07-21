# Database Migration Documentation

## Migration 003: Auth Integration and Privacy Enhancements

**Version**: 1.2 → 1.3  
**Date**: 2025-01-21

### Overview
This migration integrates with Supabase Auth and adds privacy enhancements to protect organizer email addresses.

### Key Changes

#### 1. **Field Naming Alignment**
- Renamed `allow_late_joins` to `allow_mid_event_joins` to match PRD terminology
- This clarifies that the feature is for NEW players joining mid-event, not late arrivals

#### 2. **Supabase Auth Integration**
- Added `auth_id` column to `users` table
- Links to Supabase's built-in `auth.users` table
- Enables magic link authentication as specified in PRD

#### 3. **Privacy Enhancement**
- Created `public_events` view that excludes organizer emails
- Grants public SELECT access to the view
- Protects sensitive organizer information from public queries

#### 4. **Documentation**
- Added table and column comments for clarity
- Guides developers to use the appropriate view

### Post-Migration Steps

1. **Configure Supabase Auth**:
   - Enable Email Auth in Supabase Dashboard
   - Configure magic link settings
   - Set up email templates

2. **Update Application Queries**:
   - Use `public_events` view for unauthenticated users
   - Use `events` table directly only for authenticated organizers

3. **User Registration Flow**:
   - When creating organizers, create both `auth.users` and `public.users` records
   - Link them via the `auth_id` column

### Testing
```sql
-- Verify the view works correctly
SELECT * FROM public_events;

-- Ensure organizer emails are not exposed
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'public_events' AND column_name = 'email';
-- Should return 0 rows
```

### Rollback Instructions
```sql
-- Revert field name
ALTER TABLE events RENAME COLUMN allow_mid_event_joins TO allow_late_joins;

-- Remove auth integration
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_auth_id_fkey;
ALTER TABLE users DROP COLUMN IF EXISTS auth_id;

-- Remove view
DROP VIEW IF EXISTS public_events;

-- Remove comments
COMMENT ON TABLE events IS NULL;
COMMENT ON VIEW public_events IS NULL;
```

---

## Migration 002: Error Logging and Email Notifications

**Version**: 1.1 → 1.2  
**Date**: 2025-01-21

### Overview
This migration adds comprehensive error logging and admin notification capabilities to support the security requirements in the PRD.

### Key Changes

#### 1. **Error Logs Table**
- Added `error_logs` table to track all system errors
- Includes error type, message, stack trace, user/event context
- Supports marking errors as resolved
- Admin-only access via RLS policies

#### 2. **Email Queue Table**
- Added `email_queue` table for pending notifications
- Tracks delivery attempts and status
- Enables retry logic for failed sends

#### 3. **Automatic Notifications**
- PostgreSQL trigger `notify_admin_on_error()` 
- Automatically creates email queue entries when errors occur
- Sends to first admin, falls back to organizer if no admin exists

#### 4. **Row Level Security**
- Admin-only read access to error logs
- Service role can insert errors (from application)
- Email queue managed by service role

### Post-Migration Steps

1. **Set up Email Delivery** (choose one):
   - **Option A**: Create Supabase Edge Function to process email queue
   - **Option B**: Configure Database Webhook to call external service

2. **Configure Email Service**:
   - SendGrid, Resend, or other SMTP service
   - Store API keys securely in Supabase Vault

3. **Test Error Logging**:
   ```sql
   -- Insert test error (as service role)
   INSERT INTO error_logs (error_type, error_message, stack_trace)
   VALUES ('system', 'Test error', 'Test stack trace');
   
   -- Check email queue
   SELECT * FROM email_queue WHERE sent = false;
   ```

### Rollback Instructions
```sql
-- Remove triggers
DROP TRIGGER IF EXISTS error_log_email_trigger ON error_logs;

-- Remove functions
DROP FUNCTION IF EXISTS notify_admin_on_error();

-- Remove tables (CASCADE will remove dependent objects)
DROP TABLE IF EXISTS email_queue CASCADE;
DROP TABLE IF EXISTS error_logs CASCADE;
```

---

## Migration 001: PRD Alignment Updates

**Version**: 1.0 → 1.1  
**Date**: 2025-01-21

### Overview
This migration aligns the database schema with the Product Requirements Document (PRD) to ensure all features can be properly implemented.

### Key Changes

#### 1. **Event Timezone Support**
- Added `timezone` column to `events` table (default: `America/Edmonton`)
- Ensures correct local time display for event schedules

#### 2. **Bye Round Tracking**
- Added to `event_players`:
  - `last_bye_round`: Prevents consecutive bye assignments
  - `total_bye_rounds`: Tracks fairness distribution
- Enables the round-robin algorithm to distribute bye rounds fairly

#### 3. **Late Join Support**
- Added `joined_at_round` to `event_players` (default: 1)
- Allows players to join mid-event
- Statistics calculate only from their join round forward
- Removed `check_in_time` as events don't start until all players present

#### 4. **Additional Rounds**
- Added `is_additional` to `rounds` table
- Distinguishes between scheduled rounds and extra rounds added during event

#### 5. **Print Settings**
- Added `print_settings` JSONB to `events` table
- Stores layout preferences for consistent printing

#### 6. **Enhanced Standings**
- Updated `player_standings` view to:
  - Account for `joined_at_round`
  - Only count matches from rounds after joining
  - Prepare for head-to-head tiebreaker implementation

#### 7. **Head-to-Head Tiebreaker**
- Added `get_head_to_head_winner()` function
- Implements PRD requirement for proper tiebreaker sequence:
  1. Total wins
  2. Head-to-head result
  3. Point differential
  4. Total points scored

#### 8. **Player Statistics Table**
- New `player_statistics` table for cross-event tracking
- Foundation for future ELO/rating system
- Tracks lifetime performance metrics

#### 9. **Helper Functions**
- `calculate_match_duration()`: Auto-calculates match duration
- `validate_court_assignment()`: Ensures courts exist in event configuration

### Migration Instructions

#### For New Installations
Use the updated `schema.sql` file which includes all changes.

#### For Existing Databases
Run the migration script:
```bash
# Option 1: Via Supabase Dashboard
# Copy contents of 001_prd_alignment_updates.sql and run in SQL Editor

# Option 2: Via Supabase CLI
supabase db push migrations/001_prd_alignment_updates.sql

# Option 3: Direct PostgreSQL
psql -h your-host -U postgres -d your-db -f migrations/001_prd_alignment_updates.sql
```

### Breaking Changes
- Removed `check_in_time` from `event_players` table
- `player_standings` view structure changed to include `joined_at_round`

### Data Migration
No data migration required. New columns have appropriate defaults:
- `timezone`: 'America/Edmonton'
- `joined_at_round`: 1
- `is_additional`: false
- `print_settings`: Default JSON object

### Testing Checklist
After migration, verify:
- [ ] Events show correct timezone
- [ ] Late-joining players can be added with proper round number
- [ ] Standings calculate correctly for late joiners
- [ ] Head-to-head function returns correct results
- [ ] Court validation trigger works properly
- [ ] Match duration auto-calculates on completion

### Rollback
To rollback this migration:
```sql
-- Remove new columns
ALTER TABLE events DROP COLUMN IF EXISTS timezone;
ALTER TABLE events DROP COLUMN IF EXISTS print_settings;
ALTER TABLE event_players DROP COLUMN IF EXISTS joined_at_round;
ALTER TABLE event_players DROP COLUMN IF EXISTS last_bye_round;
ALTER TABLE event_players DROP COLUMN IF EXISTS total_bye_rounds;
ALTER TABLE rounds DROP COLUMN IF EXISTS is_additional;

-- Re-add removed column
ALTER TABLE event_players ADD COLUMN check_in_time TIMESTAMPTZ;

-- Drop new table
DROP TABLE IF EXISTS player_statistics;

-- Drop new functions
DROP FUNCTION IF EXISTS get_head_to_head_winner;
DROP FUNCTION IF EXISTS calculate_match_duration;
DROP FUNCTION IF EXISTS validate_court_assignment;

-- Recreate original player_standings view
-- (Copy from original schema.sql)
```