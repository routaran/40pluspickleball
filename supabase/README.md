# Supabase Database Schema for 40+ Pickleball Platform

## Overview
This directory contains the PostgreSQL database schema for the 40+ Pickleball round robin event management system.

## Schema Features

### Court Management
- Courts are stored as a JSONB array in the `events` table
- Organizers can define custom court identifiers (e.g., "C9", "C10", "North 1", "South 2")
- Matches store the actual court assignment directly (no translation needed)

### Core Tables
1. **users** - Organizers/admins who manage events (integrated with Supabase Auth)
2. **events** - Single-day round robin tournaments with court configurations
3. **players** - Participants (not authenticated users)
4. **event_players** - Players registered for each event
5. **rounds** - Track round-by-round progression
6. **matches** - Individual games with court assignments
7. **match_players** - Players/teams in each match
8. **match_scores** - Match results
9. **error_logs** - System error tracking with admin notifications
10. **email_queue** - Pending email notifications for admins
11. **public_events** (view) - Privacy-safe view of events for public access

### Key Features
- UUID primary keys for all tables
- Comprehensive indexes for performance
- Row Level Security (RLS) policies
- Views for standings and match details
- Automatic timestamp updates
- Support for player departures and match regeneration
- Integration with Supabase Auth for magic link authentication
- Privacy protection via public_events view

## Schema Version
Current Version: **1.3** (includes auth integration and privacy enhancements)

## Deployment Instructions

### For New Installations

### Option 1: Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy the entire contents of `schema.sql`
4. Paste and run in the SQL Editor
5. The schema includes sample data - remove the last section if not needed

### Option 2: Supabase CLI
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Link to your project
supabase link --project-ref your-project-ref

# Run the migration
supabase db push schema.sql
```

### Option 3: Direct PostgreSQL Connection
```bash
# Connect to your Supabase database
psql -h db.your-project-ref.supabase.co -p 5432 -d postgres -U postgres -f schema.sql
```

### For Existing Databases

#### Upgrading from v1.0 to v1.1
If you have an existing database with version 1.0:
```bash
# Via Supabase Dashboard
# Copy contents of migrations/001_prd_alignment_updates.sql and run in SQL Editor

# Via Supabase CLI
supabase db push migrations/001_prd_alignment_updates.sql

# Via Direct PostgreSQL
psql -h db.your-project-ref.supabase.co -p 5432 -d postgres -U postgres -f migrations/001_prd_alignment_updates.sql
```

#### Upgrading from v1.1 to v1.2
To add error logging and email notifications:
```bash
# Via Supabase Dashboard
# Copy contents of migrations/002_error_logging_with_notifications.sql and run in SQL Editor

# Via Supabase CLI
supabase db push migrations/002_error_logging_with_notifications.sql

# Via Direct PostgreSQL
psql -h db.your-project-ref.supabase.co -p 5432 -d postgres -U postgres -f migrations/002_error_logging_with_notifications.sql
```

#### Upgrading from v1.2 to v1.3
To add auth integration and privacy enhancements:
```bash
# Via Supabase Dashboard
# Copy contents of migrations/003_auth_integration_and_privacy.sql and run in SQL Editor

# Via Supabase CLI
supabase db push migrations/003_auth_integration_and_privacy.sql

# Via Direct PostgreSQL
psql -h db.your-project-ref.supabase.co -p 5432 -d postgres -U postgres -f migrations/003_auth_integration_and_privacy.sql
```

See `migrations/README.md` for detailed migration information.

## Post-Deployment Steps

1. **Enable Authentication**
   - Enable Email Auth in Supabase Dashboard
   - Configure magic link authentication settings
   - Customize email templates for your branding
   - Set authentication rate limits as needed

2. **Configure Storage** (if needed for future features)
   - Create buckets for event documents or player photos

3. **Set up Environment Variables**
   - Add your Supabase URL and anon key to your React app

4. **Test RLS Policies**
   - Verify public read access works
   - Test organizer write permissions

## Court Configuration Examples

```sql
-- Example 1: Numbered courts
UPDATE events 
SET courts = '["C9", "C10", "C11", "C12"]'::jsonb
WHERE id = 'your-event-id';

-- Example 2: Named courts
UPDATE events 
SET courts = '["North 1", "North 2", "South 1", "South 2"]'::jsonb
WHERE id = 'your-event-id';

-- Example 3: Mixed identifiers
UPDATE events 
SET courts = '["Main", "C2", "Back Court", "Court D"]'::jsonb
WHERE id = 'your-event-id';
```

## Useful Queries

### View current round matches with court assignments
```sql
SELECT 
    m.match_number,
    m.court_assignment,
    team1_players,
    team2_players,
    m.status
FROM match_details m
JOIN rounds r ON m.round_id = r.id
WHERE r.event_id = 'your-event-id'
AND r.status = 'active'
ORDER BY m.match_number;
```

### Get player standings
```sql
SELECT * FROM player_standings
WHERE event_id = 'your-event-id'
ORDER BY ranking;
```

### Check available courts for an event
```sql
SELECT 
    name,
    courts,
    jsonb_array_length(courts) as court_count
FROM events
WHERE id = 'your-event-id';
```

## Error Logging and Notifications

### Error Tracking
The system includes comprehensive error logging:
- All errors are logged to the `error_logs` table
- Errors include type (auth/api/validation/system), message, stack trace, and context
- Admin users can view error logs through the application
- Errors can be marked as resolved

### Email Notifications
When an error occurs:
1. A trigger automatically creates an entry in the `email_queue` table
2. The queue entry contains the recipient email (admin or organizer)
3. To send actual emails, you need to:
   - Create a Supabase Edge Function to process the queue
   - Configure an email service (SendGrid, Resend, etc.)
   - OR use Database Webhooks to call an external service

### Viewing Error Logs
```sql
-- View recent errors
SELECT 
    error_type,
    error_message,
    created_at,
    resolved
FROM error_logs
WHERE created_at > NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;

-- View pending email notifications
SELECT 
    to_email,
    subject,
    created_at,
    attempts
FROM email_queue
WHERE sent = false
ORDER BY created_at;

-- View public events (safe for unauthenticated users)
SELECT * FROM public_events
WHERE event_date >= CURRENT_DATE
ORDER BY event_date, start_time;
```

## Privacy and Security

### Using the Public Events View
When building your application:
- **Unauthenticated users**: Query `public_events` view instead of `events` table
- **Authenticated organizers**: Can query `events` table directly
- This protects organizer email addresses from public exposure

### Authentication Flow
1. Organizers sign up/log in using magic links (no passwords)
2. Supabase sends a login link to their email
3. Clicking the link authenticates them
4. The `users.auth_id` links to Supabase's auth system

## Notes

- The schema includes sample data at the bottom - remove for production
- All timestamps are stored in UTC
- Courts are validated client-side to ensure they exist in the event's court array
- The system supports both singles and doubles matches (controlled by position in match_players)
- Error logs require admin role to view (enforced by RLS)
- Email queue is processed by external services (Edge Functions or webhooks)