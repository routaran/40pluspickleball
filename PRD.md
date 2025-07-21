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
[UI/UX guidelines and accessibility standards]

### 5.2 Key Pages/Screens
[List of main pages and their purposes]

### 5.3 Responsive Design
[Mobile, tablet, and desktop considerations]

## 6. API & Integration Requirements
### 6.1 Supabase Integration
- Database operations
- Real-time subscriptions (if needed)
- Storage requirements

### 6.2 Third-party Services
[Any additional integrations needed]

## 7. Performance Requirements
### 7.1 Load Time Targets
[Page load speed requirements]

### 7.2 Scalability
[Expected user load and growth]

### 7.3 Availability
[Uptime requirements]

## 8. Constraints & Limitations
### 8.1 Technical Constraints
- Client-side only execution (GitHub Pages limitation)
- Static hosting constraints
- Browser compatibility requirements

### 8.2 Budget Constraints
[Cost considerations for services]

## 9. Success Metrics
### 9.1 Key Performance Indicators
[How success will be measured]

### 9.2 User Engagement Metrics
[Specific metrics to track]

## 10. Timeline & Milestones
### 10.1 Development Phases
[MVP and future phases]

### 10.2 Key Deliverables
[Major milestones and deadlines]

## 11. Open Questions & Decisions
### 11.1 Architecture Decisions
- [ ] Frontend framework selection
- [ ] State management approach
- [ ] Build and deployment pipeline

### 11.2 Feature Decisions
[Features under consideration]

## 12. Appendices
### 12.1 Glossary
[Technical terms and pickleball-specific terminology]

### 12.2 References
[Related documents and resources]
