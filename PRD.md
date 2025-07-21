# Product Requirements Document - 40+ Pickleball Website

## 1. Executive Summary
### 1.1 Product Overview
A web application designed to organize and manage single-day pickleball round robin events for our local pickleball group. The system automatically generates match pairings using a rotation algorithm that ensures each player partners with different players throughout the event and faces new opponents in each game. When players leave early, the system regenerates remaining matches to maintain fair play. The application displays match results and standings as soon as scores are entered by organizers. Players can view schedules and standings without logging in via mobile devices or printed schedules posted courtside.

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
- Establish a foundation for future skill-based matchmaking using historical data to develop player ratings (e.g., ELO system)
- Reduce the time organizers spend on manual scheduling from 30+ minutes to under 5 minutes
- Collect timing data (match durations, round completion times) to improve future event planning

## 2. Product Features & User Stories
### 2.1 Core Features
1. **Dynamic Homepage** - Different views for authenticated vs unauthenticated users
2. **Event Management** - Create and configure round robin events
3. **Player Roster Management** - Add/remove players, handle changes during event
4. **Automated Match Generation** - Create fair pairings with rotation algorithm
5. **Sequential Round Management** - Progress through rounds as scores are completed, with option to add additional rounds if time permits
6. **Score Entry and Tracking** - Record results and calculate standings
7. **Public Match Viewing** - See upcoming matches and historical results without login
8. **Standings with Tiebreaker Logic** - Rank players using wins, head-to-head, point differential, and total points
9. **Mid-Event Player Addition** - Allow new players to join an active event (when enabled)
10. **Print/Export Functionality** - Generate printable schedules and standings for courtside posting
11. **Secure Organizer Access** - Authentication system for administrative functions

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
10. Log in securely to access organizer features
11. Create a new round robin event with date/time
12. Set number of available courts
13. Configure match scoring rules (games to X, win by 2)
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

### 2.3 User Stories

**1. Event Day Setup**
- As an organizer, I want to create a new event event with player roster and court settings so that I can quickly start the day's round robin matches
- As an organizer, I want to print the generated match schedule so that I can post physical copies at each court
- As an organizer, I cannot start the event until all registered players are marked present or no-show, ensuring accurate initial pairings

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
- As an organizer, I want the system to minimize consecutive bye rounds for any player so that wait times are distributed fairly

**9. Additional Rounds**
- As an organizer, I want to add additional rounds when we finish early so that we can maximize our court time
- As a player, I want to continue playing in additional rounds when available so that I get more games in during the event

## 3. Technical Architecture
### 3.1 Technology Stack
- **Frontend**: React 18+ with TypeScript, Vite, React Router, Tailwind CSS, TanStack Query
- **Backend**: Supabase
- **Hosting**: GitHub Pages
- **Authentication**: Supabase Authentication

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

**error_logs** - System error tracking for administrator monitoring
- id (UUID, primary key)
- error_type (auth/api/validation/system)
- error_message
- stack_trace
- user_id (FK to users, nullable)
- event_id (FK to events, nullable)
- browser_info (JSONB with user agent, platform, etc.)
- created_at
- resolved (boolean, default false)
- resolved_at, resolved_by (FK to users)

#### Data Integrity Rules

1. **Immutable Completed Matches**: Matches with recorded scores cannot be regenerated or modified when players leave
2. **Event Start Requirements**: Events cannot begin until all registered players are marked present or no-show
3. **Mid-Event Join Statistics**: Players joining after event start have statistics calculated only from their join round forward
4. **Bye Round Distribution**: System tracks bye history to prevent consecutive bye assignments
5. **Court Assignment Validation**: Court assignments must match available courts configured for the event

### 3.4 Terminology Clarifications

- **Mid-Event Player Addition**: Feature allowing NEW players (not previously registered) to join an active event. Not for handling late-arriving registered players
- **No-show**: A registered player who is marked absent before event start, removed from all pairings
- **Departed Player**: A player who leaves during the event, triggering regeneration of future matches only
- **Immutable Match**: A completed match with recorded scores that cannot be changed by system regeneration
- **Bye Round**: A round where a player sits out due to odd numbers, tracked to ensure fair distribution
- **Active Round**: The current round where matches are being played and scores entered
- **Additional Rounds**: Extra rounds added after completing the initially scheduled rounds

### 3.5 Supabase-Managed Features

The following features are handled entirely by Supabase and require NO custom implementation:

#### Authentication & Sessions
- **Magic Link Authentication**: Supabase Auth sends and validates login emails
- **JWT Token Management**: Access tokens (1-hour default) and refresh tokens
- **Session State**: All session data managed by Supabase, no custom tables needed
- **Session Duration**: Configurable in Supabase dashboard (7-day default)
- **Idle Timeout**: Available as Supabase Pro feature (2-hour configured)
- **Token Refresh**: Automatic handling of token renewal
- **Logout**: Supabase clears all session data

#### Security & Rate Limiting  
- **Login Attempt Rate Limiting**: 5 attempts per hour per email (Supabase Auth)
- **API Rate Limiting**: 20 requests per minute per user (Supabase project settings)
- **Email Verification**: Built into Supabase Auth flow
- **Password Reset**: Not applicable (using passwordless auth)

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

## 4. Security Requirements
### 4.1 HTTPS & Encryption
- All traffic served over HTTPS via GitHub Pages (automatic)
- TLS 1.2+ encryption for all Supabase API communications (mobile browser compatible)
- Supabase API keys stored in environment variables during build process (Vite)
- Authentication tokens stored in localStorage with 7-day expiration
- Database encryption at rest provided by Supabase

### 4.2 Authentication & Authorization
- **Authentication Method**: Magic link email authentication via Supabase Auth
  - Organizers provide email address for passwordless login
  - Supabase sends secure login links (1-hour expiration)
  - No password management required
- **User Roles**:
  - Public/Player: View-only access to events, schedules, and standings
  - Organizer: Full event creation and management capabilities
- **Session Management** (Handled entirely by Supabase Auth):
  - 7-day session duration with automatic refresh (Supabase configuration)
  - 2-hour idle timeout - activity resets timer (Supabase Pro feature)
  - Explicit logout clears all stored tokens
  - No custom database tables needed - Supabase manages all session state
- **Security Measures** (Enforced by Supabase):
  - Rate limiting: 5 login attempts per email per hour (Supabase Auth feature)
  - API rate limiting: 20 requests per minute per user (Supabase project setting)
  - Email verification required for new organizer accounts
  - No custom implementation required for these security features

### 4.3 Data Protection
- **Personal Data Collected**:
  - Players: Names only (no email/phone required)
  - Organizers: Email addresses (for authentication only)
- **Data Retention**: Indefinite storage for historical records and statistics
- **Access Control**:
  - Public users can view all event data
  - Only organizers can create/modify events and enter scores
  - Organizer emails are never displayed publicly
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
  - System logging: Full error details saved to `error_logs` table
  - Admin notifications: Email alerts for critical errors via Supabase Edge Functions
- **API Error Responses**:
  - Never expose database structure or internal system details
  - Log detailed errors server-side for debugging
  - Return only safe, generic error messages to clients
- **Supabase Row Level Security (RLS)**:
  - Mandatory for all tables to secure data with public API keys
  - Public read access for events, matches, and standings
  - Organizer-only write access for all data modifications
  - Admin-only access to error_logs table

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

The application consists of 13 primary pages organized into three categories: public access, organizer-only access, and special purpose pages. Each page is designed to support specific workflows identified in the user capabilities and stories.

#### Public Pages (Unauthenticated Access)

##### 1. Home/Events List Page
**Purpose**: Central hub for event discovery and navigation
- List all events (past, present, future) with time-aware sorting
- Today's events highlighted at top
- "Event in progress" indicators
- Quick filters (upcoming, past, today)
- Links to event details

##### 2. Event Details Page
**Purpose**: Complete view of a specific event
- Event info (date, time, courts, format)
- Current round indicator
- All rounds with expandable match lists
- Quick jump navigation to specific rounds
- Player roster with presence status
- Links to dedicated views (schedule, standings)

##### 3. Current Round Schedule Page
**Purpose**: Quick player lookup for active matches
- Large, scannable list of current round matches
- Court assignments prominently displayed
- Player names first for easy self-finding
- Partner identification
- Match status indicators
- Clear "BYE" marking for players sitting out
- Visual indicator for players with consecutive bye prevention active
- Print-optimized layout option

##### 4. Standings Page
**Purpose**: Real-time tournament rankings
- Win/loss records
- Point differentials
- Tiebreaker information
- Visual ranking indicators
- Updates immediately after score entry
- Auto-refresh indicator showing when data was last updated
- Loading state during live updates

##### 5. Player Statistics Page
**Purpose**: Individual performance history
- Cross-event statistics
- Historical match results
- Win percentage trends
- Partner performance data

#### Authenticated Pages (Organizer Access)

##### 6. Organizer Dashboard
**Purpose**: Central management hub for organizers
- Quick actions (create event, manage active events)
- Today's event shortcuts

##### 7. Create Event Page
**Purpose**: New event setup
- Event details form (name, date, time)
- Court configuration
- Scoring format settings
- Player roster builder
- Mid-event join toggle
- Print settings configuration

##### 8. Event Management Page
**Purpose**: Active event control center
- Player check-in interface with present/no-show/unchecked status toggles
- Generate pairings button with loading indicator during generation
- Round progression controls
- Player removal/addition tools
- Event status management
- Links to specialized views
- Progress feedback for bulk player operations
- Disabled state for action buttons during processing

##### 9. Score Entry Page
**Purpose**: Efficient match result recording
- Court-centric or match-list view toggle
- Large touch targets for mobile
- Common score quick-select buttons
- Batch entry support
- Progress indicators
- Missing scores highlighted
- Submission confirmation with loading state
- Prevent double-submission with button disabling
- Success feedback after score saved

##### 10. Schedule Management Page
**Purpose**: View and modify generated schedules
- Full tournament bracket view
- Regeneration controls for departed players
- Visual differentiation of regenerated matches
- Visual indicators for immutable (completed) matches
- Round-by-round navigation
- Add additional rounds option
- Progress indicator during match regeneration
- Loading state while calculating new pairings

##### 11. Print/Export Page
**Purpose**: Generate physical documents
- Schedule print preview (by court or consolidated)
- Standings print preview
- Layout customization options
- Direct print or PDF download
- Document generation progress indicator
- Loading state during PDF creation

#### Special Purpose Pages

##### 12. Login Page
**Purpose**: Organizer authentication
- Email input for magic link
- Clear instructions
- Link to return to public view

##### 13. Round Transition Page
**Purpose**: Between-round status and actions
- Completion status of current round
- List of matches needing scores
- "Advance to Next Round" button (when ready)
- Round statistics summary
- Processing indicator during round advancement
- Clear feedback when round successfully advanced

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

##### Mobile-First Pages (Must be flawless on phones)

**Current Round Schedule Page**:
- Large court numbers for quick identification
- Player names prominent and scannable
- Minimal scrolling to find matches
- Partner names clearly visible
- Touch-friendly spacing throughout

**Score Entry Page**:
- Oversized score buttons for easy tapping
- One-thumb reachable controls
- Clear match identification at top
- No precision tapping required
- Confirmation before submission

**Standings Page**:
- Essential columns only on mobile (Rank, Name, W-L, Points)
- Horizontal scroll for additional statistics
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

#### Real-time Subscriptions

Real-time subscriptions enable live updates across all connected clients without page refresh, critical for tournament management.

**What are Real-time Subscriptions:**
- WebSocket connections that listen for database changes
- Automatic UI updates when data changes on any client
- Essential for multi-device coordination during events

**Tables Requiring Real-time Subscriptions:**

1. **match_scores** (Critical)
   - Subscribe to INSERT events
   - Updates standings immediately for all viewers
   - Shows match completion in real-time

2. **matches** (Critical)
   - Subscribe to UPDATE events on `status` field
   - Shows when matches start/complete
   - Updates schedule displays instantly

3. **rounds** (Important)
   - Subscribe to UPDATE events on `status` field
   - Notifies when rounds advance
   - Activates next round for all viewers

4. **event_players** (Important)
   - Subscribe to UPDATE events on `status` field
   - Shows check-in progress in real-time
   - Updates player counts dynamically

**Subscription Patterns:**
```javascript
// Example: Subscribe to scores for a specific event
const subscription = supabase
  .channel('match-scores')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'match_scores',
    filter: `match_id=in.(${matchIds})`
  }, handleScoreUpdate)
  .subscribe()
```

**Connection Management:**
- Establish subscriptions on event detail/schedule pages
- Clean up subscriptions on page navigation
- Handle reconnection for network interruptions
- Limit subscriptions to current event for performance

#### Authentication Integration

**Magic Link Authentication Flow:**
1. User enters email on login page
2. Supabase sends magic link email
3. User clicks link to authenticate
4. Session created with 7-day duration
5. Frontend stores session in localStorage

**Session Management:**
- Check session validity on app load
- Refresh tokens automatically before expiration
- Clear session on explicit logout
- Redirect to login when session expires

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

## 7. Constraints & Limitations
### 7.1 Technical Constraints

#### Client-side Execution Constraints
- All business logic must execute in the browser (pairing algorithms, standings calculations, schedule generation)
- No server-side processing available for computationally intensive operations
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
- [ ] Frontend framework selection
- [ ] State management approach
- [ ] Build and deployment pipeline

### 8.2 Feature Decisions
[Features under consideration]

## 9. Appendices
### 9.1 Glossary
[Technical terms and pickleball-specific terminology]

### 9.2 References
[Related documents and resources]
