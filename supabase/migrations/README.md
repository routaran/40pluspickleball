# Database Migration Documentation

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