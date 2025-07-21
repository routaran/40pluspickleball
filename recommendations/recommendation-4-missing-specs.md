# Recommendation 4: Missing Specifications - Detailed Requirements

## Executive Summary

This document addresses critical missing specifications identified in the PRD, specifically focusing on timezone handling, scoring rules, and bye handling. These specifications are essential for proper implementation and must be clearly defined to avoid ambiguity during development.

## 1. List of All Missing or Vague Specifications

### Critical Missing Specifications:
1. **Timezone Handling** - Only mentions "America/Edmonton" as default but no implementation details
2. **Scoring Rules** - Mentions "games to X, win by 2" but lacks complete ruleset
3. **Bye Handling Specifics** - References bye rounds but no assignment algorithm
4. **Match Duration** - No specified time limits or estimates
5. **Round Timing** - No specifications for round start/end times
6. **Player Check-in Process** - Limited details on timing and workflow
7. **No-show Handling** - Timing cutoffs not specified
8. **Tiebreaker Rules** - Listed but not fully detailed
9. **Court Assignment Algorithm** - Not specified beyond "automatic"
10. **Partner Rotation Rules** - No specific algorithm defined
11. **Consecutive Bye Prevention** - Mentioned but not detailed
12. **Mid-Event Join Timing** - "timing restrictions apply" but not specified

### Ambiguous Areas:
- "Fair rotation" - needs mathematical definition
- "Minimize consecutive bye rounds" - needs specific rules
- "Smart defaults" for scores - what constitutes common scores?
- "Regeneration" logic for departed players
- Error recovery procedures
- Network failure handling during critical operations

## 2. Detailed Timezone Handling Specification

### 2.1 Default Configuration
```javascript
const TIMEZONE_CONFIG = {
  default: 'America/Edmonton',
  supported: [
    'America/Edmonton',    // Mountain Time (primary)
    'America/Vancouver',   // Pacific Time
    'America/Toronto',     // Eastern Time
    'America/Winnipeg',    // Central Time
  ]
};
```

### 2.2 Storage Specification
- **Database Storage**: All timestamps stored in UTC
- **Event Table**: `timezone` column stores IANA timezone identifier
- **Display Format**: All times displayed in event's configured timezone

### 2.3 Implementation Requirements

#### Database Schema
```sql
-- events table
timezone VARCHAR(50) NOT NULL DEFAULT 'America/Edmonton' 
  CHECK (timezone IN ('America/Edmonton', 'America/Vancouver', 'America/Toronto', 'America/Winnipeg'))
```

#### Time Display Rules
1. **Event Creation**: 
   - Show timezone selector with default pre-selected
   - Display example: "10:00 AM MST"
   
2. **Event Viewing**:
   - Always show times in event's timezone
   - Include timezone abbreviation in displays
   - Example: "Starts at 9:00 AM MST"

3. **Current Time Comparisons**:
   - Convert server UTC to event timezone for "active now" indicators
   - Handle DST transitions automatically

#### API Data Format
```typescript
interface EventTimes {
  event_date: string;      // ISO date (YYYY-MM-DD)
  start_time: string;      // 24-hour format (HH:MM)
  timezone: string;        // IANA identifier
  utc_timestamp: string;   // Computed UTC ISO timestamp
}
```

### 2.4 User Interface Requirements
- Display timezone name on event pages
- Show countdown timers in local time with timezone note
- Print schedules must include timezone

## 3. Complete Scoring Rules Documentation

### 3.1 Standard Game Formats

#### Rally Scoring to 11
```typescript
interface RallyScoring11 {
  type: 'rally_11';
  winningScore: 11;
  winByMargin: 2;
  capScore: 15;  // Hard cap if enabled
  switchSides: 6; // Switch at 6 points
}
```

#### Rally Scoring to 15
```typescript
interface RallyScoring15 {
  type: 'rally_15';
  winningScore: 15;
  winByMargin: 2;
  capScore: 21;  // Hard cap if enabled
  switchSides: 8; // Switch at 8 points
}
```

#### Rally Scoring to 21
```typescript
interface RallyScoring21 {
  type: 'rally_21';
  winningScore: 21;
  winByMargin: 2;
  capScore: 25;  // Hard cap if enabled
  switchSides: 11; // Switch at 11 points
}
```

### 3.2 Scoring Rules Engine

```typescript
interface ScoringRules {
  format: 'rally_11' | 'rally_15' | 'rally_21';
  winByTwo: boolean;
  hardCap: boolean;
  capScore?: number;
  timeLimit?: number; // Optional time limit in minutes
}

function isValidScore(score1: number, score2: number, rules: ScoringRules): boolean {
  const higher = Math.max(score1, score2);
  const lower = Math.min(score1, score2);
  
  // Check if someone reached winning score
  if (higher < rules.winningScore) return false;
  
  // Check win-by-two rule
  if (rules.winByTwo && (higher - lower) < 2) {
    // Check hard cap
    if (rules.hardCap && higher >= rules.capScore) {
      return true; // At cap, win by 1 is allowed
    }
    return false;
  }
  
  return true;
}
```

### 3.3 Score Entry Validation
- Minimum score: 0
- Maximum score: capScore (if defined) or winningScore + 10
- Both scores cannot be below winningScore - 2
- Quick-select options: Common final scores based on format

### 3.4 Common Score Patterns
```typescript
const COMMON_SCORES = {
  rally_11: [
    [11, 9], [11, 7], [11, 5], [11, 3],
    [12, 10], [13, 11], [15, 13] // win-by-2 scenarios
  ],
  rally_15: [
    [15, 13], [15, 11], [15, 9], [15, 7],
    [16, 14], [17, 15], [21, 19] // win-by-2 scenarios
  ],
  rally_21: [
    [21, 19], [21, 17], [21, 15], [21, 13],
    [22, 20], [23, 21], [25, 23] // win-by-2 scenarios
  ]
};
```

## 4. Bye Round Handling Specifics

### 4.1 Bye Assignment Algorithm

```typescript
interface ByeAssignment {
  strategy: 'distributed' | 'sequential';
  constraints: {
    maxConsecutiveByes: 1;
    preferNoBye: string[]; // Player IDs who should avoid byes
  };
}

function assignByes(
  players: Player[],
  roundNumber: number,
  byeHistory: Map<string, number[]>
): string | null {
  // Sort players by bye count (ascending) and last bye round (ascending)
  const candidates = players
    .map(p => ({
      player: p,
      byeCount: byeHistory.get(p.id)?.length || 0,
      lastByeRound: Math.max(...(byeHistory.get(p.id) || [0]))
    }))
    .sort((a, b) => {
      // First priority: fewer total byes
      if (a.byeCount !== b.byeCount) return a.byeCount - b.byeCount;
      // Second priority: longest time since last bye
      return a.lastByeRound - b.lastByeRound;
    });
  
  // Select player with fewest byes and longest time since last bye
  return candidates[0].player.id;
}
```

### 4.2 Bye Distribution Rules

1. **Initial Assignment**: 
   - Random selection for first round bye
   - Record in `event_players.last_bye_round`

2. **Subsequent Rounds**:
   - No player gets 2nd bye until all have had 1
   - No consecutive byes unless unavoidable
   - Track in `event_players.total_bye_rounds`

3. **Mid-Event Joins**:
   - New players get priority for next bye
   - Inherit average bye count of existing players

### 4.3 Bye Round Display
```typescript
interface ByeMatch {
  id: string;
  round_id: string;
  is_bye: true;
  bye_player_id: string;
  display_text: "BYE - Sitting out this round";
  court_assignment: null;
}
```

## 5. Match Duration and Round Timing Specifications

### 5.1 Expected Match Durations

```typescript
const MATCH_DURATION_ESTIMATES = {
  rally_11: {
    average: 15,  // minutes
    minimum: 8,
    maximum: 25,
    buffer: 5     // between matches
  },
  rally_15: {
    average: 20,
    minimum: 12,
    maximum: 30,
    buffer: 5
  },
  rally_21: {
    average: 30,
    minimum: 20,
    maximum: 45,
    buffer: 5
  }
};
```

### 5.2 Round Timing Calculations

```typescript
function calculateRoundDuration(
  matchCount: number,
  courtCount: number,
  scoringFormat: string
): number {
  const estimates = MATCH_DURATION_ESTIMATES[scoringFormat];
  const parallelSets = Math.ceil(matchCount / courtCount);
  return parallelSets * (estimates.average + estimates.buffer);
}

function estimateEventDuration(
  playerCount: number,
  roundCount: number,
  courtCount: number,
  scoringFormat: string
): {
  totalMinutes: number;
  endTime: Date;
} {
  const matchesPerRound = Math.floor(playerCount / 4) * 2;
  const minutesPerRound = calculateRoundDuration(
    matchesPerRound,
    courtCount,
    scoringFormat
  );
  
  return {
    totalMinutes: roundCount * minutesPerRound,
    endTime: // calculated from start time
  };
}
```

### 5.3 Round Progression Rules

1. **Automatic Timing**: Track actual match completion times
2. **Warning Thresholds**: Alert if round exceeds expected duration by 50%
3. **Display Requirements**: Show estimated completion time for event

## 6. Player Check-in/No-show Handling Details

### 6.1 Check-in Window Specification

```typescript
interface CheckInConfig {
  windowStart: -30;        // 30 minutes before event
  windowEnd: 15;          // 15 minutes after start
  graceperiod: 5;         // 5 minute grace after window
  autoNoShow: true;       // Auto-mark after grace period
}
```

### 6.2 Check-in States and Transitions

```typescript
enum PlayerStatus {
  REGISTERED = 'registered',
  CHECKED_IN = 'checked_in',
  NO_SHOW = 'no_show',
  DEPARTED = 'departed'
}

const STATUS_TRANSITIONS = {
  registered: ['checked_in', 'no_show'],
  checked_in: ['departed'],
  no_show: ['checked_in'], // Allow late arrival
  departed: [] // Terminal state
};
```

### 6.3 Check-in Process Flow

1. **Pre-Event (T-30 to T-0)**:
   - Display check-in UI to organizer
   - Show countdown to event start
   - Allow bulk check-in operations

2. **Event Start (T+0)**:
   - Require all players marked present/no-show
   - Block match generation until complete
   - Show warning for unmarked players

3. **Grace Period (T+0 to T+15)**:
   - Allow late check-ins
   - Regenerate first round if needed
   - Log late arrivals

4. **Post Grace Period (T+15+)**:
   - No-shows cannot be checked in
   - Only mid-event join if enabled

### 6.4 UI Requirements

```typescript
interface CheckInUI {
  displayMode: 'list' | 'grid';
  quickActions: {
    checkInAll: boolean;
    markRemaining: 'no_show' | 'departed';
  };
  showCountdown: boolean;
  blockers: {
    message: string;
    canOverride: boolean;
  }[];
}
```

## 7. Tiebreaker Rules Clarification

### 7.1 Complete Tiebreaker Hierarchy

```typescript
interface TiebreakerRules {
  order: [
    'wins',           // 1. Total wins
    'headToHead',     // 2. Head-to-head result
    'pointDiff',      // 3. Point differential
    'pointsFor',      // 4. Total points scored
    'pointsAgainst',  // 5. Total points allowed
    'initialSeed'     // 6. Random seed assigned at start
  ];
}
```

### 7.2 Head-to-Head Calculation

```typescript
function calculateHeadToHead(
  player1: string,
  player2: string,
  matches: Match[]
): -1 | 0 | 1 {
  const h2hMatches = matches.filter(m => 
    m.hasPlayer(player1) && m.hasPlayer(player2)
  );
  
  if (h2hMatches.length === 0) return 0;
  
  let player1Wins = 0;
  let player2Wins = 0;
  
  h2hMatches.forEach(match => {
    const p1Team = match.getPlayerTeam(player1);
    const p2Team = match.getPlayerTeam(player2);
    
    if (p1Team === p2Team) {
      // Were partners, check if they won
      if (match.winningTeam === p1Team) {
        player1Wins += 0.5;
        player2Wins += 0.5;
      }
    } else {
      // Were opponents
      if (match.winningTeam === p1Team) player1Wins++;
      else player2Wins++;
    }
  });
  
  if (player1Wins > player2Wins) return 1;
  if (player2Wins > player1Wins) return -1;
  return 0;
}
```

### 7.3 Point Differential Rules

- Calculate as: (Points Scored - Points Allowed)
- Include all completed matches
- Bye rounds do not affect point differential
- Departed player's matches count only if completed

### 7.4 Multi-Way Tie Resolution

```typescript
function resolveMultiWayTie(players: Player[]): Player[] {
  // Step 1: Check if one player beat all others head-to-head
  const clearWinner = findClearH2HWinner(players);
  if (clearWinner) {
    return [clearWinner, ...resolveMultiWayTie(
      players.filter(p => p !== clearWinner)
    )];
  }
  
  // Step 2: Fall back to point differential within tied group
  return players.sort((a, b) => {
    const tiebreakers = ['pointDiff', 'pointsFor', 'pointsAgainst', 'initialSeed'];
    
    for (const criterion of tiebreakers) {
      const diff = a[criterion] - b[criterion];
      if (diff !== 0) return criterion === 'pointsAgainst' ? diff : -diff;
    }
    
    return 0;
  });
}
```

## 8. Additional Specifications

### 8.1 Court Assignment Algorithm

```typescript
interface CourtAssignment {
  strategy: 'sequential' | 'distributed';
  rules: {
    // Avoid same court consecutive rounds
    avoidRepeat: boolean;
    // Balance court usage
    balanceUsage: boolean;
  };
}

function assignCourts(
  matches: Match[],
  availableCourts: string[],
  previousAssignments: Map<string, string>
): Map<string, string> {
  const assignments = new Map();
  const courtUsage = new Map(availableCourts.map(c => [c, 0]));
  
  matches.forEach(match => {
    // Get courts used by these players last round
    const playersLastCourts = match.players
      .map(p => previousAssignments.get(p))
      .filter(Boolean);
    
    // Find least used court that wasn't used by these players
    const availableOptions = availableCourts
      .filter(c => !playersLastCourts.includes(c))
      .sort((a, b) => courtUsage.get(a)! - courtUsage.get(b)!);
    
    const assigned = availableOptions[0] || availableCourts[0];
    assignments.set(match.id, assigned);
    courtUsage.set(assigned, courtUsage.get(assigned)! + 1);
  });
  
  return assignments;
}
```

### 8.2 Partner Rotation Algorithm

```typescript
interface PartnerHistory {
  playerId: string;
  partners: Map<string, number>; // partnerId -> count
  opponents: Map<string, number>; // opponentId -> count
}

function selectPartner(
  player: string,
  availablePlayers: string[],
  history: Map<string, PartnerHistory>
): string {
  const playerHistory = history.get(player);
  
  // Sort by least partnered with
  const candidates = availablePlayers
    .map(p => ({
      id: p,
      partnerCount: playerHistory?.partners.get(p) || 0,
      opponentCount: playerHistory?.opponents.get(p) || 0
    }))
    .sort((a, b) => {
      // Prioritize players never partnered with
      if (a.partnerCount !== b.partnerCount) {
        return a.partnerCount - b.partnerCount;
      }
      // Then by opponent count for variety
      return a.opponentCount - b.opponentCount;
    });
  
  return candidates[0].id;
}
```

### 8.3 Mid-Event Join Timing Rules

```typescript
interface MidEventJoinRules {
  allowedUntilRound: 3;      // Can't join after round 3
  minimumRoundsToPlay: 3;    // Must be able to play 3+ rounds
  cutoffTime: 60;            // Minutes after event start
  requiresApproval: true;    // Organizer must approve
}

function canJoinMidEvent(
  event: Event,
  currentRound: number,
  elapsedMinutes: number
): { allowed: boolean; reason?: string } {
  const rules = event.midEventJoinRules;
  
  if (!event.allow_mid_event_joins) {
    return { allowed: false, reason: "Mid-event joins disabled" };
  }
  
  if (currentRound > rules.allowedUntilRound) {
    return { allowed: false, reason: "Too late in tournament" };
  }
  
  if (elapsedMinutes > rules.cutoffTime) {
    return { allowed: false, reason: "Time cutoff exceeded" };
  }
  
  const remainingRounds = event.totalRounds - currentRound;
  if (remainingRounds < rules.minimumRoundsToPlay) {
    return { allowed: false, reason: "Not enough rounds remaining" };
  }
  
  return { allowed: true };
}
```

### 8.4 Error Recovery Procedures

```typescript
interface ErrorRecovery {
  scoreEntryFailure: {
    retryAttempts: 3;
    retryDelay: 1000; // ms
    fallbackStorage: 'localStorage';
    userMessage: "Score saved locally. Will retry when connection restored.";
  };
  
  matchGenerationFailure: {
    validation: 'pre-flight';
    rollbackSupport: true;
    userMessage: "Unable to generate matches. Please check player count and courts.";
  };
  
  networkFailure: {
    offlineQueue: true;
    syncOnReconnect: true;
    indicator: 'banner';
    userMessage: "You're offline. Changes will sync when reconnected.";
  };
}
```

## 9. Implementation Priority

### High Priority (Must have for MVP):
1. Timezone handling (default only)
2. Basic scoring rules (rally to 11)
3. Simple bye assignment
4. Basic check-in flow
5. Primary tiebreaker (wins + head-to-head)

### Medium Priority (Post-MVP):
1. Additional timezones
2. Multiple scoring formats
3. Advanced bye distribution
4. Full tiebreaker hierarchy
5. Court assignment optimization

### Low Priority (Future):
1. Complex partner rotation
2. Mid-event join rules
3. Advanced error recovery
4. Offline capabilities

## 10. Acceptance Criteria

Each specification must include:
1. Clear mathematical/algorithmic definition
2. Edge case handling
3. User-facing error messages
4. Validation rules
5. UI/UX requirements
6. Database constraints
7. API response formats

These specifications provide concrete, implementable requirements that remove ambiguity from the original PRD and ensure consistent behavior across the application.