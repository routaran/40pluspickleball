# Product Requirements Document - 40+ Pickleball Website

## 1. Executive Summary
### 1.1 Product Overview
A web application designed to organize and manage single-day pickleball round robin events for our local pickleball group. The system automatically generates match pairings using a Modified Berger Tables algorithm (see Section 3.6.1) that ensures each player partners with different players throughout the event and faces new opponents in each game. When players leave early, the system regenerates remaining matches to maintain fair play. The application displays match results and standings as soon as scores are entered by organizers. Players can view schedules and standings without logging in via mobile devices or printed schedules posted courtside.

### 1.2 Target Audience
- Primary: Our local pickleball group organizers who run weekly/regular round robin events
- Secondary: All participating players (various ages and skill levels) who want to view schedules and standings
- The system is designed for private use by our specific pickleball community

### 1.3 Key Objectives
- Automate the complex task of creating round robin match schedules that ensure fair rotation
- Eliminate scheduling conflicts where players might play with/against the same people multiple times
- Provide immediate score entry and automatic standings calculation
- Create a responsive interface optimized for both desktop (event setup) and mobile (courtside use)
- Enable both digital and physical distribution of schedules and results (printable formats for courtside posting)
- Provide transparent, ranked standings with consistent tiebreaker rules
- Support dual workflows: desktop for event setup/management, mobile for courtside score entry and viewing
- Reduce the time organizers spend on manual scheduling from 30+ minutes to under 5 minutes
- Track all match history and statistics for future ranking systems
- Provide a solid foundation that can grow with additional features based on actual usage

## 2. Product Features & User Stories
### 2.1 Core Features
1. **Dynamic Homepage** - Different views for authenticated vs unauthenticated users
2. **Event Management** - Create and configure round robin events
3. **Player Roster Management** - Add/remove players, handle changes during event
4. **Automated Match Generation** - Create fair pairings using Modified Berger Tables algorithm with partnership optimization
5. **Sequential Round Management** - Progress through rounds as scores are completed, with option to add additional rounds if time permits
6. **Score Entry and Tracking** - Record results and calculate standings
7. **Public Match Viewing** - See upcoming matches and historical results without login
8. **Standings with Tiebreaker Logic** - Rank players using wins, head-to-head, point differential, and total points
9. **Mid-Event Player Addition** - Allow new players to join an active event (when enabled)
10. **Print/Export Functionality** - Generate printable schedules and standings for courtside posting
11. **Secure Organizer Access** - Hybrid authentication: magic link for initial setup, email/password for subsequent logins with 30-day sessions

### 2.2 User Capabilities

**Unauthenticated Users (Players/Public) can:**
1. View a full listing of all events (past, present, and future)
2. Access detailed information for any event (matchups, results, standings)
3. View current day's match schedule with court assignments
4. See which round is currently active for today's event
5. View player pairings for each match
6. Check current standings and rankings
7. Access historical match results
8. View individual player statistics
9. Access the site from mobile devices at courtside

**Authenticated Users (Organizers/Admins) can do everything above PLUS:**
10. Log in securely with email/password (30-day sessions with "Remember me" option)
11. Create a new round robin event with date/time
12. Set number of available courts
13. Configure match scoring rules (flexible system: 9/11/15 points with win-by-2 or first-to-target)
14. Add new players to an active event if "mid-event player addition" is enabled (timing restrictions apply)
15. Remove players from the roster (before or during event)
16. Generate round robin match pairings
17. View and modify the generated schedule
18. Enter match scores after completion (including from mobile devices at courtside)
19. Advance to the next round (after all scores entered)
20. Add additional rounds when the scheduled rounds complete early
21. Export/print match schedules for courtside posting
22. Export/print current standings
23. View event management dashboard
24. Access and manage all events they've organized
25. Mark registered players as no-shows and start event without them

#### 2.2.1 Flexible Scoring System

The application supports 6 scoring configurations to accommodate different play styles and time constraints:

**Scoring Options**:
- **Target Points**: 9, 11, or 15 points
- **Win Conditions**: 
  - Win by 2 (games can continue indefinitely, e.g., 25-23)
  - First to target (straight race to the target score)

**All 6 Combinations**:
1. **9 points, win by 2** - Quick games with traditional rules
2. **9 points, first to 9** - Fixed length quick games
3. **11 points, win by 2** - Standard pickleball scoring
4. **11 points, first to 11** - Fixed length standard games
5. **15 points, win by 2** - Extended competitive games
6. **15 points, first to 15** - Fixed length extended games

**Score Validation**:
- Valid win-by-2 scores: 11-9, 11-8, 12-10, 13-11 (no cap)
- Valid first-to-target scores: 9-8, 11-10, 15-14
- Invalid scores: negative scores, both teams reaching target, win-by-1 when win-by-2 is required

### 2.3 User Stories

**1. Event Day Setup and Check-in**
- As an organizer, I want to create a new event with player roster and court settings so that I can quickly start the day's round robin matches
- As an organizer, I want to manually mark each player as present when they arrive at the venue
- As an organizer, I can only start the event when ALL registered players are marked as present, ensuring complete participation
- As an organizer, I want to print the pre-generated match schedule so that I can post physical copies at each court
- As an organizer, I control when the event starts with no automatic timing or scheduled start times

**2. Player Departure Handling**
- As an organizer, I want to remove a player who left early and regenerate fair matches for remaining players so that the event can continue smoothly without manual re-scheduling
- When a player leaves early, only future unplayed matches are regenerated. Completed matches with recorded scores remain unchanged

**3. Round Progression**
- As an organizer, I want the system to lock the next round until all current scores are entered so that players don't start matches out of sequence
- As an organizer, I want to see clearly which matches still need scores so that I can track down results and advance the event

**4. Courtside Score Entry**
- As an organizer, I want to enter match scores from my mobile phone at courtside so that I can update results immediately without returning to a computer

**5. Player Match Lookup**
- As a player, I want to see all matches for the current round in a single view so that I can quickly find my name and see which court I'm assigned to
- As a player, I want to see who my partner is for each match so that I can find them before our match starts

**6. Quick Standings Check**
- As a player, I want to view current standings with win/loss records and tiebreakers so that I understand my ranking in the event

**7. Event Discovery**
- As a player, I want to see a list of all upcoming events so that I can plan which events to attend
- As a player, I want to view details of past events so that I can see my historical match results

**8. Bye Round Management**
- As a player, I want to clearly see when I have a bye round so that I know when I'm sitting out
- As an organizer, I want the system to distribute bye rounds fairly using priority-based assignment (see Section 3.6.3) so that wait times are distributed evenly

**9. Additional Rounds**
- As an organizer, I want to add additional rounds when we finish early so that we can maximize our court time
- As a player, I want to continue playing in additional rounds when available so that I get more games in during the event

**10. Long Event Session Management**
- As an organizer, I want my login session to persist throughout a 3-hour event without timing out so that I can manage the tournament without interruption
- As an organizer, I want a "Remember me" option so that I don't have to log in repeatedly on my personal devices
- As an organizer, I want to set a password after my first magic link login so that future logins are quick and don't require email access

**11. Partnership Variety**
- As a player, I want to partner with different people each round so that the event is more social and fair
- As a player, I want to play against different opponents when possible so that matches remain interesting

**12. Player Departure Handling**
- As an organizer, I want the system to handle player departures gracefully without disrupting completed matches
- As a player, I want to know that my completed matches won't be affected if someone leaves early

## 3. Technical Architecture
### 3.1 Technology Stack
- **Frontend**: React 18+ with TypeScript, Vite, React Router, Tailwind CSS, TanStack Query
- **Backend**: Supabase
- **Hosting**: GitHub Pages
- **Authentication**: Supabase Authentication (hybrid: magic link + password)

### 3.2 Architecture Diagram

#### High-Level Architecture Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER'S BROWSER                             │
│                                                                     │
│  1. User visits https://[your-github-username].github.io/40plus...  │
│  2. GitHub Pages serves static files (HTML, JS, CSS)                │
│  3. React app loads and executes entirely in browser                │
│  4. App makes API calls directly to Supabase from browser           │
│  5. All algorithms and logic run client-side                        │
└─────────────────────────────────────────────────────────────────────┘
```

#### Detailed Component Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CLIENT BROWSER                               │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │                    REACT APPLICATION (SPA)                      │ │
│ │                                                                 │ │
│ │  ┌──────────────────────────────────────────────────────────┐   │ │
│ │  │                    ROUTING LAYER                         │   │ │
│ │  │  ┌────────────────────┐  ┌─────────────────────────┐     │   │ │
│ │  │  │   Public Routes    │  │  Protected Routes       │     │   │ │
│ │  │  │                    │  │  (Organizer Only)       │     │   │ │
│ │  │  │ /                  │  │ /admin/create-event     │     │   │ │
│ │  │  │ /events            │  │ /admin/manage-event/:id │     │   │ │
│ │  │  │ /event/:id         │  │ /admin/enter-scores     │     │   │ │
│ │  │  │ /standings/:eventId│  │                         │     │   │ │
│ │  │  └────────────────────┘  └─────────────────────────┘     │   │ │
│ │  └──────────────────────────────────────────────────────────┘   │ │
│ │                                                                 │ │
│ │  ┌──────────────────────────────────────────────────────────┐   │ │
│ │  │              BUSINESS LOGIC (Client-Side Only)           │   │ │
│ │  │                                                          │   │ │
│ │  │  ┌─────────────────┐  ┌─────────────────┐                │   │ │
│ │  │  │ Round Robin     │  │ Standings       │                │   │ │
│ │  │  │ Pairing Algorithm│ │ Calculator      │                │   │ │
│ │  │  │                 │  │                 │                │   │ │
│ │  │  │ - Rotation logic│  │ - Win/Loss      │                │   │ │
│ │  │  │ - Bye handling  │  │ - Head-to-head  │                │   │ │
│ │  │  │ - Court assign  │  │ - Point diff    │                │   │ │
│ │  │  │ - Re-generation │  │ - Tiebreakers   │                │   │ │
│ │  │  └─────────────────┘  └─────────────────┘                │   │ │
│ │  │                                                          │   │ │
│ │  │  ┌─────────────────┐  ┌─────────────────┐                │   │ │
│ │  │  │ Print Generator │  │ Schedule        │                │   │ │
│ │  │  │                 │  │ Manager         │                │   │ │
│ │  │  │ - CSS @media    │  │                 │                │   │ │
│ │  │  │ - Page breaks   │  │ - Round progress│                │   │ │
│ │  │  │ - Court layouts │  │ - Match status  │                │   │ │
│ │  │  └─────────────────┘  └─────────────────┘                │   │ │
│ │  └──────────────────────────────────────────────────────────┘   │ │
│ │                                                                 │ │
│ │  ┌──────────────────────────────────────────────────────────┐   │ │
│ │  │                    DATA LAYER                            │   │ │
│ │  │                                                          │   │ │
│ │  │  ┌─────────────────┐  ┌─────────────────┐                │   │ │
│ │  │  │ Supabase Client │  │ TanStack Query  │                │   │ │
│ │  │  │                 │  │                 │                │   │ │
│ │  │  │ - Auth tokens   │  │ - Cache API     │                │   │ │
│ │  │  │ - CRUD ops      │  │   responses     │                │   │ │
│ │  │  │ - Realtime subs │  │ - Optimistic    │                │   │ │
│ │  │  │                 │  │   updates       │                │   │ │
│ │  │  └─────────────────┘  └─────────────────┘                │   │ │
│ │  │                                                          │   │ │
│ │  │  ┌─────────────────────────────────────┐                 │   │ │
│ │  │  │      Browser Storage                │                 │   │ │
│ │  │  │  - LocalStorage (temp state)        │                 │   │ │
│ │  │  │  - SessionStorage (auth tokens)     │                 │   │ │
│ │  │  └─────────────────────────────────────┘                 │   │ │
│ │  └──────────────────────────────────────────────────────────┘   │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         GITHUB PAGES                                │
│                    (Static File Server Only)                        │
│                                                                     │
│  ┌────────────┐  ┌──────────────┐  ┌────────────┐  ┌────────────┐   │
│  │index.html  │  │   main.js    │  │ styles.css │  │   assets/  │   │
│  │            │  │  (bundled    │  │ (Tailwind) │  │            │   │
│  │            │  │   React app) │  │            │  │            │   │
│  └────────────┘  └──────────────┘  └────────────┘  └────────────┘   │
│                                                                     │
│  Build Process (happens before deployment):                         │
│  - TypeScript → JavaScript compilation                              │
│  - React JSX → JavaScript transformation                            │
│  - Bundle all code with Vite                                        │
│  - Minify and optimize                                              │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ API Calls (from browser)
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            SUPABASE                                 │
│                                                                     │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────┐     │
│  │   PostgreSQL   │  │  Auth Service  │  │  Realtime Engine   │     │
│  │                │  │                │  │                    │     │
│  │ Tables:        │  │ - JWT tokens   │  │ - Score updates    │     │
│  │ - events       │  │ - Sessions     │  │ - New matches      │     │
│  │ - players      │  │ - Organizers   │  │ - Standings change │     │
│  │ - matches      │  │                │  │                    │     │
│  │ - scores       │  │                │  │                    │     │
│  └────────────────┘  └────────────────┘  └────────────────────┘     │
└─────────────────────────────────────────────────────────────────────┘
```

#### Key Data Flows

**A. Unauthenticated User Views Event:**
```
1. User visits site → GitHub Pages serves index.html + JS bundle
2. React app boots in browser
3. React Router shows public event list component
4. Component uses TanStack Query to fetch from Supabase
5. Supabase returns event data
6. React renders the UI
```

**B. Organizer Creates Round Robin:**
```
1. Organizer logs in (Supabase Auth)
2. Navigates to create event (React Router)
3. Enters players and settings
4. Clicks "Generate Matches"
5. JavaScript algorithm runs IN BROWSER:
   - Calculates all pairings
   - Assigns courts
   - Handles byes
6. Results saved to Supabase
7. UI updates to show matches
```

**C. Score Entry and Standings Update:**
```
1. Organizer enters score on mobile
2. React component sends to Supabase
3. Other users' browsers receive realtime update
4. Each browser independently calculates standings:
   - Fetches all match results
   - Runs tiebreaker algorithm locally
   - Displays updated standings
```

#### Architecture Decisions

1. **Client-Side Algorithms:** All business logic executes in the browser due to GitHub Pages static hosting constraint
2. **React + Vite:** Provides excellent state management for complex UI and fast development experience
3. **TanStack Query:** Intelligent caching layer reduces API calls and improves performance
4. **Supabase Integration:** Handles all backend services (database, auth, realtime) via API calls from browser

### 3.3 Data Models

#### Core Database Tables

**users** - Event organizers who can create and manage events
- id (UUID, primary key)
- email (unique)
- display_name
- role (organizer/admin)
- password_set (boolean, default false)
- last_login (timestamp)
- created_at, updated_at

**events** - Single-day round robin tournaments
- id (UUID, primary key)
- name
- event_date, start_time
- created_by (FK to users)
- status (draft/active/completed/cancelled)
- courts (JSONB array of court identifiers)
- scoring_format (JSONB with game rules)
- max_players
- allow_mid_event_joins (boolean for new players joining after start)
- timezone (default: America/Edmonton)
- print_settings (JSONB for print preferences)

**players** - Participants in events (no authentication required)
- id (UUID, primary key)
- name
- email, phone (optional)
- skill_level (2.5-5.0)
- notes
- Unique constraint on (name, email, phone)

**event_players** - Links players to events they're participating in
- event_id, player_id (composite primary key)
- check_out_time (when player leaves early)
- status (registered/departed/no_show)
- joined_at_round (for mid-event joins)
- last_bye_round, total_bye_rounds (for fair bye distribution)

**rounds** - Tournament rounds within an event
- id (UUID, primary key)
- event_id (FK)
- round_number
- status (pending/active/completed)
- is_additional (boolean for rounds added after initial schedule)

**matches** - Individual games within rounds
- id (UUID, primary key)
- event_id, round_id (FKs)
- match_number
- court_assignment
- status (pending/in_progress/completed/cancelled)
- is_bye (boolean)

**match_players** - Assigns players to teams and positions
- match_id, player_id (FKs)
- team (1 or 2)
- position (1 or 2 for doubles)
- Unique constraints on (match_id, player_id) and (match_id, team, position)

**match_scores** - Records match results
- match_id (FK, unique)
- team1_score, team2_score
- winning_team
- duration_minutes
- recorded_by (FK to users)

**player_statistics** - Aggregate performance data
- player_id (FK, primary key)
- Various totals and calculated fields (win percentage, point differential)

#### 3.3.1 Match Duration Tracking

Match duration is tracked for statistical analysis and future event planning:

**Implementation**:
- Start time recorded when organizer begins entering score (first keystroke)
- End time recorded when score is saved
- Duration calculated as: (end_time - start_time) / 60000 (minutes)
- Stored in match_scores.duration_minutes field

**Purpose**:
- Analyze typical match lengths for different scoring formats
- Improve future event time estimates
- No scheduling enforcement - purely for statistics

#### Data Integrity Rules

1. **Immutable Completed Matches**: Matches with recorded scores cannot be regenerated or modified when players leave
2. **Event Start Requirements**: Events cannot begin until all registered players are marked present or no-show
3. **Mid-Event Join Statistics**: Players joining after event start have statistics calculated only from their join round forward
4. **Bye Round Distribution**: System assigns byes fairly based on total bye count
5. **Court Assignment Validation**: Court assignments must match available courts configured for the event

### 3.4 Terminology Clarifications

**Player Status Types**:
- **Registered**: Player added to event roster but not yet arrived
- **Present**: Player checked in and ready to participate
- **No-show**: Player didn't arrive, not included in event pairings
- **Departed**: Player left during event, future matches affected

**Event Terms**:
- **Mid-Event Player Addition**: Feature allowing NEW players (not previously registered) to join an active event
- **Immutable Match**: A completed match with recorded scores that cannot be changed by system regeneration
- **Bye Round**: A round where a player sits out due to odd numbers, tracked to ensure fair distribution
- **Active Round**: The current round where matches are being played and scores entered
- **Additional Rounds**: Extra rounds added after completing the initially scheduled rounds

**Check-in Process**:
- Manual process with no automatic timing
- Event starts only when ALL players marked present
- Organizer controls entire workflow
- Pre-generated pairings allow printed schedules

#### 3.3.2 Data Validation Rules

All user inputs must pass validation before database storage:

**Player Names**:
- Length: 2-50 characters
- Pattern: Letters, spaces, hyphens, apostrophes only
- Required field

**Event Names**:
- Length: 5-100 characters
- Required field

**Courts**:
- Minimum: 1 court
- Maximum: 10 courts
- Must be array of court identifiers

**Player Limits**:
- Minimum: 4 players (required for doubles)
- Maximum: 32 players
- No specific divisibility requirement

**Score Validation**:
- Non-negative integers only
- Must follow scoring rules for selected format
- Winner must have higher score
- Validated against selected scoring preset

### 3.5 Supabase-Managed Features

The following features are handled entirely by Supabase and require NO custom implementation:

#### Authentication & Sessions
- **Hybrid Authentication**: Magic link for initial setup, email/password for subsequent logins
- **Password Authentication**: Standard email/password with configurable requirements
- **JWT Token Management**: Access tokens with extended 30-day duration
- **Session State**: All session data managed by Supabase, no custom tables needed
- **Session Duration**: 30 days for long event support (configurable)
- **Auto-Refresh**: Sessions refresh automatically when less than 1 hour remains
- **Remember Me**: Optional persistent sessions for trusted devices
- **Password Reset**: Magic link for secure password recovery

#### Security & Rate Limiting  
- **Login Attempt Rate Limiting**: 5 attempts per hour (Supabase Auth)
- **API Rate Limiting**: 20 requests per minute per user (Supabase project settings)
- **Email Verification**: Built into Supabase Auth flow for initial setup
- **Password Requirements**: Minimum 8 characters with at least one number

#### Database Features
- **Connection Pooling**: Managed by Supabase
- **SSL/TLS Encryption**: Automatic for all database connections
- **Backups**: Daily backups on Pro plan
- **Row Level Security (RLS)**: Native PostgreSQL feature via Supabase

#### Real-time Features
- **WebSocket Connections**: Managed by Supabase Realtime
- **Subscription Management**: Automatic cleanup of disconnected clients
- **Presence Tracking**: Available but not currently used

**Important**: These features work out-of-the-box with proper Supabase configuration. No custom code, database tables, or middleware required.

### 3.6 Algorithm Specifications

This section defines the core algorithms that power the round-robin pairing system. These algorithms execute entirely client-side in the browser due to the static hosting architecture.

#### 3.6.1 Round-Robin Pairing Algorithm
**Purpose**: Generate a complete tournament schedule ensuring each player partners with different players and faces diverse opponents.

**Approach**: Modified Berger Tables algorithm adapted for doubles play
- Creates systematic rotation of players across rounds
- Ensures no repeated partnerships when mathematically possible
- Handles odd number of players with bye assignments
- Optimizes for both partnership variety and opponent diversity

**Requirements**:
- Input: List of players (4-32)
- Output: Complete schedule for all rounds
- Constraint: Minimize repeated partnerships and matchups
- Performance: < 100ms generation time for 16 players

#### 3.6.2 Doubles Partnership Management
**Purpose**: Track and optimize player partnerships to maximize variety in pairings.

**Key Features**:
- Tracks all previous partnerships in the event
- Tracks all previous opponent matchups
- Scores potential pairings based on novelty
- Penalizes repeated partnerships more heavily than repeated opponents

**Scoring System**:
- -10 points for repeated partnership
- -5 points for repeated opponent matchup
- Algorithm selects pairing with highest score

#### 3.6.3 Bye Round Distribution
**Purpose**: Fairly distribute bye rounds when player count doesn't divide evenly by 4.

**Distribution Logic**:
- Players with fewest total byes get priority
- Ties broken by longest time since last bye
- No consecutive byes unless mathematically unavoidable
- Tracks bye history throughout event

**Implementation Details**:
```
Player Bye Tracking Structure:
{
  playerId: string
  totalByes: number
  byeRounds: number[]  // Array of round numbers where player had bye
  lastByeRound: number // Most recent bye round (-1 if never)
}
```

**Consecutive Bye Prevention**:
1. Sort players by totalByes (ascending), then lastByeRound (ascending)
2. For each bye slot in current round:
   - Skip players with lastByeRound === currentRound - 1 (had bye last round)
   - Select next eligible player from sorted list
   - If all remaining players had bye last round, allow consecutive (unavoidable)
3. Update tracking after assignment

**Mid-Event Adjustment Rules**:
- When player leaves mid-event:
  - Preserve existing bye history
  - Recalculate future bye assignments
  - Ensure departing player's byes don't create imbalance
  - Redistribute future byes among remaining players
- When player joins mid-event:
  - Initialize with totalByes = 0
  - Consider them highest priority for next bye

**Requirements**:
- Fair distribution across all players
- Clear communication of bye assignments
- Support for mid-event recalculation
- Bye fairness report showing distribution

#### 3.6.4 Court Assignment
**Purpose**: Allocate available courts to matches efficiently.

**Assignment Strategy**:
- Sequential assignment based on match order
- Support for court preferences (future enhancement)
- Waiting queue when matches exceed courts
- Clear position indicators for waiting matches

**Court Rotation Policy**:
- Players remain on assigned court for entire round
- No mid-round court changes
- New court assignments only between rounds
- Ensures match completion without disruption

#### 3.6.5 Match Regeneration
**Purpose**: Handle player departures without disrupting completed matches.

**Regeneration Rules**:
- Preserve all completed matches (immutable)
- Regenerate only future rounds from departure point
- Maintain bye distribution fairness
- Recalculate partnerships for remaining players

**Constraints**:
- Never modify matches with recorded scores
- Maintain tournament integrity
- Clear indication of regenerated matches

#### 3.6.6 Performance Characteristics
- **Round-robin generation**: O(n²) time complexity
- **Court assignment**: O(n log n) time complexity
- **Bye assignment**: O(n log n) time complexity
- **Match regeneration**: O(n² × r) where r = remaining rounds
- **Browser performance**: All operations complete in < 100ms for typical 16-player events

**Note**: Detailed algorithm implementations including pseudocode and test cases are maintained in `/recommendations/recommendation-2-define-algorithms.md`. This PRD focuses on requirements and high-level specifications.

#### 3.6.7 Tiebreaker Algorithm
**Purpose**: Determine final rankings when players have identical win-loss records.

**Tiebreaker Sequence** (applied in order):
1. **Total Wins** - Most wins ranked higher
2. **Head-to-Head** - Direct match result if tied players faced each other
3. **Point Differential** - Total points scored minus points allowed
4. **Total Points Scored** - Higher total ranked higher
5. **Total Points Against** - Fewer points allowed ranked higher
6. **Stable Sort** - Consistent ordering for final ties

**Implementation**: Applied after all matches complete to generate final standings. Each criterion is evaluated only if previous criteria result in a tie.

## 4. Security Requirements
### 4.1 HTTPS & Encryption
- All traffic served over HTTPS via GitHub Pages (automatic)
- TLS 1.2+ encryption for all Supabase API communications (mobile browser compatible)
- Supabase API keys stored in environment variables during build process (Vite)
- Authentication tokens stored in localStorage with 30-day expiration
- Database encryption at rest provided by Supabase

### 4.2 Authentication & Authorization
- **Authentication Method**: Hybrid approach for long event support
  - Initial setup: Magic link for secure account creation and email verification (24-hour expiration)
  - Password setup: Required after first login via set-password page
  - Subsequent logins: Email/password authentication
  - Password reset: Magic link for security
- **Password Requirements**:
  - Minimum 8 characters
  - Maximum 128 characters
  - At least one number
  - No uppercase or special characters required (keeping it simple for pickleball community)
- **User Roles**:
  - Public/Player: View-only access to events, schedules, and standings
  - Organizer: Full event creation and management capabilities
- **Session Management** (Extended for long events):
  - 30-day session duration to handle multi-hour events without re-authentication
  - Automatic session refresh when less than 1 hour remains
  - "Remember me" option for persistent sessions on trusted devices
  - Sessions persist through entire event without timeout
  - 7-day idle timeout for security
- **Security Measures**:
  - Rate limiting: 5 login attempts per hour
  - Force re-authentication for sensitive actions (delete event)
  - Login audit trail for security monitoring
  - "Logout all devices" option available

### 4.3 Data Protection
- **Personal Data Collected**:
  - Players: Names only (no email/phone required)
  - Organizers: Email addresses (for authentication only)
- **Data Retention**: Indefinite storage for historical records and statistics
- **Access Control**:
  - Public users can view all event data
  - Only organizers can create/modify events and enter scores
  - Organizer emails are never displayed publicly
- **Score Entry Permissions**:
  - Only the event organizer (creator) can enter/modify scores
  - No delegation or multi-organizer support in MVP
  - Scores can only be entered for matches in "pending" status
  - Completed match scores cannot be modified (must delete and re-enter)
  - Score entry requires active authentication session
  - Session must be validated before each score submission
- **Privacy Policy**: Simple one-page policy required covering:
  - Data collected (player names, organizer emails)
  - Purpose (organizing pickleball events)
  - No data selling or external sharing
  - Contact information for privacy questions

### 4.4 Application Security
- **Input Validation**:
  - Sanitize all user inputs (names, scores, event details)
  - Validate score ranges and formats
  - Prevent script injection in player names
- **XSS Prevention**: React's automatic escaping for all rendered content
- **SQL Injection Prevention**: Supabase prepared statements and parameterized queries
- **CORS Configuration**: Restrict Supabase project to accept requests only from GitHub Pages domain
- **Security Headers**:
  - Content Security Policy (CSP) to prevent unauthorized scripts
  - X-Frame-Options to prevent clickjacking
  - X-Content-Type-Options to prevent MIME sniffing

### 4.5 Operational Security
- **Error Handling**:
  - User-facing: Generic "Something went wrong. Please try again." messages
  - Console logging: Minimal error details for debugging during development
  - No persistent error storage or admin notifications needed
- **API Error Responses**:
  - Never expose database structure or internal system details
  - Return only safe, generic error messages to clients
  - Use browser console for debugging in production
- **Supabase Row Level Security (RLS)**:
  - Mandatory for all tables to secure data with public API keys
  - Public read access for events, matches, and standings
  - Organizer-only write access for all data modifications
  - Implemented in migration file: `004_security_hardening.sql`

## 5. User Interface Requirements
### 5.1 Design Principles

The user interface should prioritize efficiency and clarity for both player groups: organizers managing events and players checking schedules/standings. All design decisions should support the core workflows of event setup, match discovery, score entry, and standings tracking.

#### 1. Simplicity & Clarity
- Use large, readable text appropriate for the age demographic
- Provide clear button labels instead of icon-only navigation
- Maintain minimal navigation depth (maximum 3 levels)
- Use straightforward terminology familiar to pickleball players

#### 2. Mobile-Optimized for Courtside Use
- Implement touch-friendly targets (minimum 44px touch areas)
- Design for one-handed operation during score entry
- Provide quick access to current round matches
- Ensure responsive design works seamlessly on all screen sizes

#### 3. Efficiency for Organizers
- Support batch operations for entering multiple scores at once
- Provide smart defaults with common scores pre-filled (11-9, 11-7)
- Display clear progress indicators for event completion
- Streamline the player check-in process with bulk actions

#### 4. Information Density Balance
- Show essential information prominently (court assignments, match pairings)
- Use progressive disclosure for detailed information
- Create print-optimized layouts for physical posting
- Avoid information overload on mobile screens

#### 5. Consistency
- Maintain standard patterns throughout (forms, buttons, navigation)
- Ensure predictable behaviors across all interactions
- Use familiar terminology from the pickleball community
- Apply unified visual language and styling

#### 6. Visual Status Communication
- Provide clear indicators for match states (pending, in-progress, completed, locked)
- Visually differentiate between original and regenerated matches
- Show progress bars or completion percentages for rounds
- Highlight missing scores that block round advancement
- Use badge notifications for "action needed" items

#### 7. Scannable Layouts for Quick Discovery
- Display player names first in match lists for easy self-finding
- Offer court-centric view option for score entry workflow
- Provide alphabetical player lists with jump-to navigation
- Display court numbers prominently in large text
- Clearly indicate current round at top of page

#### 8. Print-Optimized Designs
- Include dedicated print stylesheets for schedules and standings
- Support court-by-court breakdown for posting at individual courts
- Design compact layouts that fit standard paper sizes
- Remove navigation and interactive elements from print views
- Ensure high contrast black & white printing compatibility

#### 9. State Preservation & Smart Defaults
- Remember last event viewed by each user
- Auto-focus on current/active round when opening event
- Pre-fill common scores with quick selection options
- Provide "duplicate last score" functionality
- Maintain scroll position during score entry

#### 10. Clear Action Affordances
- Keep primary actions always visible (Enter Score, Next Round)
- Require confirmation for destructive actions (Remove Player)
- Show disabled states with explanatory tooltips
- Display multi-step processes with clear progression indicators
- Provide immediate visual feedback for all user actions

#### 11. Time-Aware Interface
- Auto-highlight today's events on landing page
- Sort upcoming events by date proximity
- Visually separate past, present, and future events
- Display "Event in progress" indicators
- Show time since last update for live events

#### 12. System Feedback & Loading States
- Provide immediate visual feedback for all user actions
- Display loading indicators for any operation exceeding 0.5 seconds
- Show progress bars for multi-step operations (match generation, bulk actions)
- Disable interactive elements during processing to prevent duplicate submissions
- Display clear success confirmations or error messages upon completion
- Use skeleton screens for initial page loads
- Implement optimistic updates where appropriate for better perceived performance

#### Error Handling Patterns
- Display user-friendly error messages without technical details
- Provide actionable next steps when errors occur
- Log detailed errors for admin review (via Supabase)
- Implement retry mechanisms for transient failures
- Show offline indicators when network connectivity is lost
- Use toast notifications for non-blocking errors
- Display inline validation errors immediately
- Maintain form state during error recovery

### 5.2 Key Pages/Screens

The application consists of 7 primary pages designed to support all essential workflows while maintaining simplicity. The reduced page count improves navigation and reduces complexity for the target audience of 15-20 users.

#### Page Structure

##### 1. Home/Events List
**Purpose**: Central hub showing all events with quick statistics
- List all events (past, present, future)
- Today's events highlighted at top
- Quick stats summary for each event
- "Create New Event" button (authenticated only)
- Links to view each event

##### 2. Event Dashboard (Tabbed Interface)
**Purpose**: Complete event view combining schedule, standings, and score entry
- **Schedule Tab** (Default):
  - Current round prominently displayed
  - Court assignments and match pairings
  - Round navigation controls
  - Match completion status
  - BYE indicators
- **Standings Tab**:
  - Live rankings with win/loss records
  - Point differentials and tiebreakers
  - Updates immediately after score entry
- **Score Entry Tab** (Authenticated only):
  - Manual score input fields
  - Match-by-match entry
  - Progress indicators
  - Round advancement controls

##### 3. Create Event
**Purpose**: Simple form for event setup
- Event name and date
- Court configuration
- Scoring format selection (9/11/15 points, win by 2 or straight)
- Player roster selection
- Generate schedule button

##### 4. Player Stats
**Purpose**: Individual player history and performance analysis
- Overall record across events
- Best/worst partnerships
- Head-to-head records
- Performance trends
- Points ratio analysis

##### 5. Login
**Purpose**: Secure organizer access
- Email/password form
- "Remember me" checkbox
- Password reset link (magic link)
- First-time setup flow

##### 6. Settings
**Purpose**: Account and system management
- Change password
- Manage player roster
- Export data options
- Logout all devices

##### 7. Print View
**Purpose**: Clean layouts for physical posting
- Schedule printout
- Standings printout
- Optimized for courtside posting

#### User Flow Diagrams

**Player Flow (2-3 pages)**:
```
Home → Event Dashboard
         ├── Schedule Tab (What court am I on?)
         ├── Standings Tab (How am I doing?)
         └── Player Stats (Optional: Historical performance)
```

**Organizer Flow (3-4 pages)**:
```
Login → Home → Create Event → Event Dashboard
                                ├── Schedule Tab (View matches)
                                ├── Standings Tab (Monitor progress)
                                └── Score Entry Tab (Enter results)
```

**Key Benefit**: The consolidated Event Dashboard eliminates navigation between separate Schedule, Standings, and Score Entry pages, reducing clicks and improving efficiency.

### 5.3 Responsive Design

The application supports two primary device workflows with a mobile-first responsive approach that ensures optimal experiences for both organizers and players.

#### Core Device Workflows

**Desktop (Primary for Setup)**:
- Event creation and configuration
- Roster management and player check-in
- Schedule generation and modification
- Print/export operations

**Mobile (Primary for Courtside)**:
- Courtside score entry by organizers
- Player match lookups ("What court am I on?")
- Quick standings checks between matches

**Tablet (Optional)**:
- Alternative for any desktop or mobile workflow
- No tablet-specific features required

#### Critical Responsive Requirements

##### Mobile-First Requirements

**Event Dashboard Mobile Optimizations**:
- **Swipeable tabs** for Schedule/Standings/Score Entry
- **Sticky headers** showing current round when scrolling
- **Condensed views** with essential information only
- **Touch targets** minimum 44px for all interactive elements
- **One-thumb operation** for score entry at courtside

**Specific Tab Optimizations**:
- **Schedule Tab**: Court numbers in large text, player names prominent
- **Standings Tab**: Show only Rank, Name, W-L on mobile
- **Score Entry Tab**: Large input fields, no precision tapping required
- Current standings highlighted
- Large, readable text

##### Desktop-Optimized Pages

**Create Event & Event Management**:
- Multi-column layouts for complex forms
- All options visible without scrolling
- Drag-and-drop for roster building (optional)
- Side-by-side comparisons

**Print/Export Page**:
- Full document preview at actual size
- Print CSS independent of screen size
- Multiple layout options visible

#### Universal Responsive Patterns

**Navigation**:
- Collapsible hamburger menu on mobile
- Full horizontal navigation on desktop
- Consistent placement across all pages

**Tables**:
- Priority columns visible on mobile
- Full data tables on desktop
- Horizontal scroll indicators when needed

**Typography**:
- Base font size 16px minimum
- Larger sizes for headers and court numbers
- Line height optimized for readability

**Spacing**:
- Increased padding on mobile (minimum 44px touch targets)
- Compact spacing on desktop for information density
- Consistent margins across breakpoints

#### What NOT to Include

- Complex breakpoint systems (mobile/desktop split is sufficient)
- Orientation-specific layouts
- Device-specific features
- Offline capabilities
- App-like behaviors (pull-to-refresh, gestures)

#### Technical Implementation Notes

**CSS Architecture**:
- CSS Grid/Flexbox for fluid layouts
- rem units for scalable typography
- CSS custom properties for consistent spacing
- Mobile-first media queries (@media min-width)

**Breakpoints**:
- Mobile: 320px - 767px
- Desktop: 768px+
- No intermediate breakpoints needed

**Print Styles**:
- Separate @media print stylesheet
- Hidden navigation and interactive elements
- Optimized for 8.5" x 11" paper
- High contrast black and white compatible

### 5.4 Mobile vs Desktop Considerations

#### Mobile Optimizations (320px - 767px)
- **Tab Navigation**: Swipeable tabs on Event Dashboard for fluid navigation
- **Information Hierarchy**: Progressive disclosure to manage screen space
- **Touch Optimization**: All interactive elements minimum 44px
- **Simplified Data**: Essential columns only in tables
- **Single Column Layouts**: Stack content vertically

#### Desktop Enhancements (768px+)
- **Side-by-Side Views**: Display Schedule and Standings simultaneously
- **Expanded Data Tables**: Show all statistics without scrolling
- **Keyboard Shortcuts**: Quick score entry with Tab navigation
- **Hover States**: Additional information on hover
- **Multi-Column Forms**: Efficient use of horizontal space

#### Responsive Patterns
```css
/* Mobile First Approach */
.event-dashboard {
  display: flex;
  flex-direction: column;
}

@media (min-width: 768px) {
  .event-dashboard {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }
}
```

### 5.5 Print Layout Specifications

#### Schedule Print Format
**Layout**: Court-by-court grid view
- **Header**: Event name, date, and round number
- **Grid Structure**: 
  - Rows: Courts (Court 1, Court 2, etc.)
  - Columns: Time slots or match numbers
  - Cell content: Player names (2x2 grid for doubles)
- **Page Settings**:
  - Orientation: Landscape for > 3 courts, Portrait otherwise
  - Margins: 0.5" all sides
  - Font: 12pt body, 14pt headers
  - Page breaks: After every 2 rounds
- **Example**:
  ```
  [Event Name] - Round 3 - [Date]
  
  Court 1: Alice & Bob    vs    Carol & Dave
  Court 2: Eve & Frank    vs    Grace & Henry
  Court 3: (Waiting) Ivan & Jane vs Kim & Larry
  ```

#### Standings Print Format
**Layout**: Ranked table format
- **Header**: Event name, date, "Current Standings"
- **Table Columns**:
  1. Rank (1, 2, 3...)
  2. Player Name
  3. W-L Record
  4. Points For
  5. Points Against
  6. Point Differential
  7. Tiebreaker indicators (if applicable)
- **Formatting**:
  - Bold top 3 positions
  - Alternate row shading for readability
  - Group tied players with visual indicator
- **Page Settings**:
  - Orientation: Portrait
  - Auto-fit to single page width
  - Continue on next page if > 30 players

#### Score Entry Sheets
**Layout**: Pre-filled match cards by court
- **Card Format** (4 per page):
  ```
  ┌─────────────────────────────┐
  │ Court #__ Round #__ Match#__│
  │                             │
  │ Team 1: _________ & _______ │
  │ Score: [  ][  ][  ]         │
  │                             │
  │ Team 2: _________ & _______ │
  │ Score: [  ][  ][  ]         │
  │                             │
  │ Duration: _____ minutes     │
  └─────────────────────────────┘
  ```
- **Features**:
  - Pre-printed player names
  - Score boxes for 3 games
  - Duration field
  - Perforated for easy distribution

#### Print CSS Requirements
```css
@media print {
  /* Hide non-printable elements */
  nav, .no-print, button { display: none; }
  
  /* Force black text on white */
  * { 
    color: black !important; 
    background: white !important;
  }
  
  /* Page break controls */
  .page-break { page-break-after: always; }
  .keep-together { page-break-inside: avoid; }
  
  /* Table formatting */
  table { border-collapse: collapse; }
  th, td { 
    border: 1px solid #000; 
    padding: 4px;
  }
}
```

## 6. API & Integration Requirements
### 6.1 Supabase Integration

The application relies entirely on Supabase for backend functionality, leveraging its comprehensive feature set to eliminate the need for custom backend development.

#### Database Operations

**CRUD Operations Required:**
- **Events**: Create, read, update event details and status
- **Players**: Create and read player profiles (update rarely needed)
- **Event Players**: Create registrations, update status (present/no-show/departed)
- **Rounds**: Create rounds, update status, read for display
- **Matches**: Batch create for round generation, update status, read for schedules
- **Match Players**: Batch create for team assignments, read for display
- **Match Scores**: Create scores, read for standings calculation
- **Player Statistics**: Auto-updated via triggers, read for displays

**Batch Operations:**
- Match generation: Insert multiple matches and match_player records in single transaction
- Round creation: Create all matches for a round atomically
- Player check-in: Update multiple event_player records simultaneously

**Complex Queries:**
- Standings calculation with multi-tier tiebreakers
- Player match history across events
- Current round identification with active matches
- Head-to-head comparisons for tiebreaking
- Bye round distribution analysis

**Transaction Requirements:**
- Match regeneration: Delete future matches and create new ones atomically
- Round advancement: Update round status and create new round in transaction
- Score entry: Update match status and create score record together

#### Authentication Integration

**Hybrid Authentication Flow:**

**First-Time Organizer:**
1. Enter email on login page
2. Receive magic link email (24-hour expiration)
3. Click link → redirect to set password page
4. Create password (8+ chars, 1 number required)
5. Automatically logged in with 30-day session

**Returning Organizer:**
1. Enter email and password
2. Check "Remember me" for persistent session
3. Logged in with 30-day session
4. Session auto-refreshes during activity

**Password Recovery:**
1. Click "Forgot password?" link
2. Enter email
3. Receive magic link
4. Reset password on landing page
5. Logged in with new password

**Session Management:**
- 30-day session duration (configurable)
- Check session validity on app load
- Automatic refresh when < 1 hour remains
- 7-day idle timeout for security
- Clear session on explicit logout
- Redirect to login when session expires
- "Remember me" stores refresh token securely

**Role-based Access Control:**
- Public routes: No authentication required
- Organizer routes: Check for valid Supabase session
- Admin routes: Verify user role from users table
- Implement route guards in React Router

#### Storage Requirements

**Database Storage Only:**
- No file uploads or blob storage needed
- All data is structured and relational
- Estimated storage for 16-player events:
  - ~100KB per event (including all matches/scores)
  - ~1MB per year of regular events
  - Minimal storage costs

**Data Retention:**
- Indefinite retention for historical statistics
- No archival process needed for small dataset
- All data remains queryable for player stats

### 6.2 Third-party Services

**No Additional Services Required**

The application's requirements are fully met by Supabase's integrated platform:
- Authentication: Supabase Auth
- Database: Supabase PostgreSQL
- Real-time: Supabase Realtime
- API: Supabase auto-generated APIs

**Future Considerations:**
- Email customization: Currently uses Supabase default templates
- Advanced analytics: Could integrate with analytics service if needed
- Backup solution: Supabase handles daily backups on Pro plan

### 6.3 Data Export Formats

#### Player Statistics Export (CSV)
**Filename**: `player_stats_[date].csv`
**Structure**:
```csv
Player Name,Events Played,Total Matches,Wins,Losses,Win %,Points For,Points Against,Point Diff,Avg Match Duration
John Smith,12,156,98,58,62.82,1872,1654,218,18.5
Jane Doe,10,130,85,45,65.38,1560,1320,240,17.2
```
**Fields**:
- Player Name: Full name as registered
- Events Played: Count of events participated
- Total Matches: Sum of all matches played
- Wins/Losses: Match outcomes
- Win %: Calculated to 2 decimal places
- Points For/Against: Total game points
- Point Diff: Points For minus Points Against
- Avg Match Duration: In minutes, 1 decimal place

#### Event Data Export (JSON)
**Filename**: `event_[name]_[date].json`
**Structure**:
```json
{
  "event": {
    "name": "Saturday Doubles",
    "date": "2024-03-15",
    "format": "Round Robin",
    "scoringFormat": "Rally to 11, win by 2",
    "rounds": 8,
    "courts": 4
  },
  "players": [
    {
      "id": "uuid",
      "name": "John Smith",
      "checkIn": "2024-03-15T08:45:00Z"
    }
  ],
  "matches": [
    {
      "round": 1,
      "court": 1,
      "team1Players": ["uuid1", "uuid2"],
      "team2Players": ["uuid3", "uuid4"],
      "scores": [[11, 9], [11, 7]],
      "duration": 22,
      "completedAt": "2024-03-15T09:15:00Z"
    }
  ],
  "standings": [
    {
      "playerId": "uuid",
      "wins": 6,
      "losses": 2,
      "pointsFor": 88,
      "pointsAgainst": 72
    }
  ]
}
```

#### Summary Report Export
**Options**:
1. **Quick Summary** (CSV):
   - Final standings only
   - Player name, W-L, Points
   - Single page printable

2. **Detailed Report** (CSV):
   - Round-by-round results
   - Partnership history
   - Court assignments
   - Bye rounds

**Export Location**: Downloads folder with timestamp
**Permissions**: Organizer only
**Format Validation**: UTF-8 encoding, proper escaping for special characters

## 7. Constraints & Limitations
### 7.1 Technical Constraints

#### Client-side Execution Constraints
- **ALL business logic executes client-side in the browser**, including:
  - Round-robin pairing algorithms (Modified Berger Tables)
  - Standings calculations with tiebreakers
  - Schedule generation and regeneration
  - Partnership optimization scoring
  - Bye round distribution
  - Statistics aggregation and player performance metrics
- No server-side processing available for any calculations or data transformations
- Supabase is used purely as a data store - no database functions, triggers, or computed columns
- Algorithm performance must scale efficiently for worst-case scenarios (16 players, 10+ rounds)
- Memory management critical for batch operations (generating matches for entire event)
- Limited to JavaScript's single-threaded execution model

#### Static Hosting Limitations (GitHub Pages)
- No server-side rendering or dynamic HTML generation
- No custom backend endpoints, middleware, or API proxies
- All API calls must originate directly from browser to Supabase
- No server-side caching mechanisms or CDN configuration control
- Build artifacts limited to static files (HTML, CSS, JS, assets)
- URL structure constrained by static file paths

#### Browser Compatibility & Performance
- **Mobile Browser Support Required:**
  - iOS Safari 14+ (primary mobile platform)
  - Chrome Mobile 90+ (Android devices)
  - Must handle touch interactions for score entry
  - Responsive design mandatory for 375px-428px viewports
- **Desktop Browser Support:**
  - Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
  - Print functionality must work consistently across browsers
- **Storage Limitations:**
  - LocalStorage limited to ~10MB per origin
  - SessionStorage cleared on tab close
  - No access to filesystem for data persistence

#### Security Constraints
- Supabase anon key exposed in client-side code (secured by Row Level Security)
- No server-side validation layer (must rely entirely on database constraints and RLS)
- Authentication tokens stored in browser storage (vulnerable to XSS if not careful)
- CORS restrictions for any third-party API integrations
- All security must be enforced at database level via Supabase RLS policies

**Row Level Security (RLS) Protection:**
The exposed anon key is secured through comprehensive RLS policies that ensure:
- **Read-only access** for anonymous users (view events, players, matches, scores)
- **No write access** without authentication (cannot create/modify/delete any data)
- **Ownership-based access** for authenticated users (can only modify their own events)
- **Role-based restrictions** for sensitive data (error logs, email queue require admin role)
- **Hard delete prevention** across all tables (data integrity maintained)

See migration `004_security_hardening.sql` for complete security implementation.

#### Network & Connectivity Requirements
- Constant internet connection required (no offline capability)
- No data synchronization or conflict resolution for offline edits
- Real-time features require stable WebSocket connections
- Network latency directly impacts user experience
- No request queuing or retry mechanisms at server level
- Bandwidth considerations for real-time subscriptions with multiple concurrent users

#### Data Processing Limitations
- Complex queries (standings with tiebreakers) must execute efficiently in browser
- Large dataset operations limited by browser memory (though 16 players is well within limits)
- No background workers for long-running calculations
- CSV export and print formatting must be handled client-side
- Image processing (if ever needed) limited to browser capabilities

#### Development & Deployment Constraints
- Build process must output only static files
- No server environment variables (must use build-time substitution)
- No server logs or monitoring (only client-side error tracking possible)
- Deployment limited to GitHub Pages features and limitations
- No A/B testing or feature flags at server level
- Version rollbacks require new deployments


## 8. Open Questions & Decisions
### 8.1 Architecture Decisions
- [x] **Frontend framework**: React 18+ with TypeScript (as specified in Section 3.1)
- [x] **State management**: TanStack Query for server state + React Context for auth/global UI state
- [x] **Build and deployment pipeline**: GitHub Actions → GitHub Pages

### 8.2 Feature Decisions
- [x] **Authentication method**: Email/password with 30-day sessions (not magic link only)
- [x] **Session duration**: 30 days with auto-refresh
- [x] **Real-time updates**: Not needed (page refresh is sufficient)
- [x] **Error logging**: Not needed for 15-20 users
- [x] **Skill-based pairing**: Track skill levels for future use, but MVP uses random pairing only
- [x] **Print layouts**: Full schedule and standings
- [x] **Mobile gestures**: Not in MVP (standard touch interactions only)
- [x] **Data export**: Available in Settings for statistics
- [x] **Player photos**: Not needed (names are sufficient identification)
- [x] **Historical statistics**: Full player statistics page with performance analysis

### 8.3 Operational Policies

#### Event Cancellation Policy
**Cancellation Options**:
1. **Soft Delete** (Recommended):
   - Event marked as "cancelled" in database
   - Removed from active events list
   - Data retained for statistics
   - Can be restored if needed

2. **Archive**:
   - Move to separate "archived_events" view
   - Preserve all match and score data
   - Include in player statistics
   - Show cancellation reason

**Cancellation Rules**:
- Only event organizer can cancel
- Cancellation allowed at any point
- If matches have been played:
  - Completed matches count toward statistics
  - Partial rounds marked as incomplete
  - Standings frozen at cancellation point
- If no matches played:
  - Event can be fully deleted
  - No impact on player statistics

**Data Handling**:
- Cancellation timestamp recorded
- Optional cancellation reason field
- Email notification to organizer (future enhancement)
- Export data option before cancellation

**UI Requirements**:
- Confirmation dialog with consequences
- Option to download event data
- Clear "Cancelled" badge on event
- Removed from home page active list

#### Player Roster Management

**Add Player Workflow**:
1. Navigate to Event Dashboard
2. Click "Add Player" button
3. Enter player name (validation: 2-50 characters, letters/spaces/hyphens only)
4. Check for duplicates (case-insensitive)
5. If new player: Add to both players and event_players tables
6. If existing player: Add to event_players only
7. Regenerate affected rounds (current and future)
8. Update UI with new schedule

**Edit Player Details**:
- **Allowed Changes**:
  - Fix spelling errors in name
  - Update skill level (future use)
- **Restrictions**:
  - Cannot change name if matches completed
  - Changes apply to all future events
  - Historical data remains unchanged
- **Process**:
  1. Select player from roster
  2. Edit name in modal
  3. Confirm changes
  4. Update across all tables

**Remove Player Workflow**:
- **Before Event Starts**:
  - Simple removal from event_players
  - Regenerate all rounds
  - No statistics impact
- **During Event**:
  - Preserve completed matches
  - Mark as "withdrawn" after round X
  - Regenerate only future rounds
  - Adjust bye distribution
- **Confirmation Required**:
  - Show impact summary
  - List matches to be affected
  - Option to cancel

**Bulk Import** (Future Enhancement):
- CSV format: Name, Skill Level (optional)
- Validation before import
- Duplicate checking
- Success/error report

**Check-in Management**:
- Toggle check-in status
- Show arrival time
- Filter by checked-in status
- Prevent round start until minimum players checked in

## 9. Implementation Timeline

### Practical MVP Development Schedule (4-5 Weeks)

#### Week 1: Foundation (5 days)
- Project setup with React + TypeScript + Supabase
- Database schema implementation
- Authentication system with long sessions
- Basic routing and layout

#### Week 2: Core Features (5 days)
- Event creation and player management
- Round-robin algorithm implementation
- Match generation and court assignment
- Basic UI components

#### Week 3: Score & Statistics (5 days)
- Score entry interface
- Standings calculation
- Player statistics views
- Historical data queries

#### Week 4: Polish & Testing (5 days)
- Mobile responsive design
- Print layouts
- User testing with organizers
- Bug fixes and refinements

#### Week 5: Deployment (3 days)
- Production deployment
- Documentation
- Training for organizers

## 10. Future Enhancements

### Phase 2 (After 3-6 months of use)
1. **Ranking System**
   - ELO ratings implementation
   - Skill-based matchmaking option
   - Performance predictions

2. **Advanced Statistics**
   - Partnership chemistry analysis
   - Win probability calculations
   - Performance heat maps

3. **Schedule Optimization**
   - Minimize wait times between matches
   - Court utilization analysis
   - Smart bye assignments

### Phase 3 (If user base grows)
1. **Multi-group Support**
   - Different locations/chapters
   - Inter-group tournaments
   - Comparative statistics

2. **Real-time Features**
   - Live score updates
   - WebSocket connections
   - Presence indicators

3. **Advanced Features**
   - Tournament brackets
   - Swiss system support
   - Round-robin variations

