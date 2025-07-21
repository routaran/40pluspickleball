# Tiebreaker Algorithm Specification

## Overview

The tiebreaker system determines final rankings when multiple players have identical win-loss records. The algorithm applies a hierarchical set of criteria to ensure fair and deterministic rankings.

## Tiebreaker Hierarchy

Tiebreakers are applied in the following order:

1. **Total Wins** - Higher number of match wins
2. **Head-to-Head** - Direct match results between tied players
3. **Point Differential** - Total points scored minus points allowed
4. **Total Points Scored** - Higher total points scored
5. **Total Points Against** - Fewer points allowed (defensive performance)
6. **Stable Sort** - Consistent ordering based on player ID

## Algorithm Implementation

```typescript
interface PlayerStats {
  playerId: string;
  playerName: string;
  wins: number;
  losses: number;
  pointsFor: number;
  pointsAgainst: number;
  pointDifferential: number;
  matchResults: Map<string, MatchResult>; // opponentId -> result
}

interface MatchResult {
  won: boolean;
  pointsScored: number;
  pointsAllowed: number;
  partnerId: string;
  opponentIds: string[];
}

interface RankedPlayer extends PlayerStats {
  rank: number;
  tiebreakLevel?: string; // Which tiebreaker determined final position
}

function calculateStandings(players: PlayerStats[]): RankedPlayer[] {
  // Sort by wins first (descending)
  const sorted = [...players].sort((a, b) => b.wins - a.wins);
  
  // Group players by win count
  const tieGroups = groupByWins(sorted);
  
  // Apply tiebreakers to each group
  const rankedPlayers: RankedPlayer[] = [];
  let currentRank = 1;
  
  for (const group of tieGroups) {
    if (group.length === 1) {
      // No tie, assign rank directly
      rankedPlayers.push({
        ...group[0],
        rank: currentRank,
        tiebreakLevel: 'wins'
      });
      currentRank++;
    } else {
      // Apply tiebreakers
      const resolved = resolveTies(group);
      resolved.forEach(player => {
        rankedPlayers.push({
          ...player,
          rank: currentRank++
        });
      });
    }
  }
  
  return rankedPlayers;
}

function resolveTies(tiedPlayers: PlayerStats[]): RankedPlayer[] {
  // Try each tiebreaker in sequence
  let remaining = [...tiedPlayers];
  const resolved: RankedPlayer[] = [];
  
  // Level 2: Head-to-Head
  if (remaining.length > 1) {
    const h2hResolved = applyHeadToHead(remaining);
    resolved.push(...h2hResolved.resolved);
    remaining = h2hResolved.remaining;
  }
  
  // Level 3: Point Differential
  if (remaining.length > 1) {
    const pdResolved = applyPointDifferential(remaining);
    resolved.push(...pdResolved.resolved);
    remaining = pdResolved.remaining;
  }
  
  // Level 4: Total Points Scored
  if (remaining.length > 1) {
    const tpsResolved = applyTotalPointsScored(remaining);
    resolved.push(...tpsResolved.resolved);
    remaining = tpsResolved.remaining;
  }
  
  // Level 5: Total Points Against (fewer is better)
  if (remaining.length > 1) {
    const tpaResolved = applyTotalPointsAgainst(remaining);
    resolved.push(...tpaResolved.resolved);
    remaining = tpaResolved.remaining;
  }
  
  // Level 6: Stable Sort by Player ID
  if (remaining.length > 1) {
    remaining.sort((a, b) => a.playerId.localeCompare(b.playerId));
    remaining.forEach(p => {
      resolved.push({ ...p, rank: 0, tiebreakLevel: 'stable-sort' });
    });
  } else if (remaining.length === 1) {
    resolved.push({ ...remaining[0], rank: 0 });
  }
  
  return resolved;
}
```

## Head-to-Head Resolution

The most complex tiebreaker is head-to-head, which must handle various scenarios:

```typescript
function applyHeadToHead(players: PlayerStats[]): TiebreakerResult {
  const resolved: RankedPlayer[] = [];
  const remaining: PlayerStats[] = [];
  
  // For 2-player ties, simple comparison
  if (players.length === 2) {
    const [p1, p2] = players;
    const p1Result = p1.matchResults.get(p2.playerId);
    const p2Result = p2.matchResults.get(p1.playerId);
    
    if (p1Result && p2Result) {
      if (p1Result.won) {
        resolved.push({ ...p1, rank: 0, tiebreakLevel: 'head-to-head' });
        resolved.push({ ...p2, rank: 0, tiebreakLevel: 'head-to-head' });
      } else {
        resolved.push({ ...p2, rank: 0, tiebreakLevel: 'head-to-head' });
        resolved.push({ ...p1, rank: 0, tiebreakLevel: 'head-to-head' });
      }
    } else {
      // No head-to-head match
      remaining.push(...players);
    }
    
    return { resolved, remaining };
  }
  
  // For multi-way ties, create mini-standings
  const h2hRecords = calculateHeadToHeadRecords(players);
  
  // Sort by H2H wins
  const h2hSorted = [...h2hRecords.entries()]
    .sort(([, a], [, b]) => b.wins - a.wins);
  
  // Check if H2H clearly resolves any positions
  const h2hGroups = groupByH2HWins(h2hSorted);
  
  for (const group of h2hGroups) {
    if (group.length === 1) {
      // Clear winner/loser in H2H
      const playerId = group[0][0];
      const player = players.find(p => p.playerId === playerId)!;
      resolved.push({ ...player, rank: 0, tiebreakLevel: 'head-to-head' });
    } else {
      // Still tied after H2H
      const tiedPlayerIds = group.map(([id]) => id);
      const tiedPlayers = players.filter(p => tiedPlayerIds.includes(p.playerId));
      remaining.push(...tiedPlayers);
    }
  }
  
  return { resolved, remaining };
}

function calculateHeadToHeadRecords(
  players: PlayerStats[]
): Map<string, { wins: number; losses: number }> {
  const records = new Map();
  const playerIds = new Set(players.map(p => p.playerId));
  
  for (const player of players) {
    let wins = 0;
    let losses = 0;
    
    for (const [opponentId, result] of player.matchResults) {
      // Only count if opponent is in the tie group
      if (playerIds.has(opponentId)) {
        if (result.won) wins++;
        else losses++;
      }
    }
    
    records.set(player.playerId, { wins, losses });
  }
  
  return records;
}
```

## Handling Edge Cases

### 1. Circular Head-to-Head (A beats B, B beats C, C beats A)

```typescript
function detectCircularH2H(players: PlayerStats[]): boolean {
  if (players.length < 3) return false;
  
  const h2hRecords = calculateHeadToHeadRecords(players);
  const uniqueWinCounts = new Set(
    [...h2hRecords.values()].map(r => r.wins)
  );
  
  // If all players have same H2H record, it's circular
  return uniqueWinCounts.size === 1;
}
```

### 2. Incomplete Head-to-Head

When tied players haven't all played each other:

```typescript
function hasCompleteH2H(players: PlayerStats[]): boolean {
  const playerIds = players.map(p => p.playerId);
  
  for (const player of players) {
    const opponents = new Set(player.matchResults.keys());
    const missingOpponents = playerIds.filter(
      id => id !== player.playerId && !opponents.has(id)
    );
    
    if (missingOpponents.length > 0) return false;
  }
  
  return true;
}
```

### 3. Multi-Way Ties with Partial Resolution

```typescript
// Example: 4 players tied with 5 wins each
// A beat B, C, D (3-0 in H2H)
// B beat C, lost to A, D (1-2 in H2H)  
// C lost to A, B, beat D (1-2 in H2H)
// D lost to A, C, beat B (1-2 in H2H)

// Result: A is 1st, then apply next tiebreaker to B, C, D
```

## Point Differential Calculation

```typescript
function applyPointDifferential(players: PlayerStats[]): TiebreakerResult {
  const sorted = [...players].sort((a, b) => 
    b.pointDifferential - a.pointDifferential
  );
  
  const resolved: RankedPlayer[] = [];
  const remaining: PlayerStats[] = [];
  
  let currentDiff = sorted[0].pointDifferential;
  let group: PlayerStats[] = [];
  
  for (const player of sorted) {
    if (player.pointDifferential === currentDiff) {
      group.push(player);
    } else {
      // Differential changed, resolve previous group
      if (group.length === 1) {
        resolved.push({ 
          ...group[0], 
          rank: 0, 
          tiebreakLevel: 'point-differential' 
        });
      } else {
        remaining.push(...group);
      }
      
      group = [player];
      currentDiff = player.pointDifferential;
    }
  }
  
  // Handle last group
  if (group.length === 1) {
    resolved.push({ 
      ...group[0], 
      rank: 0, 
      tiebreakLevel: 'point-differential' 
    });
  } else {
    remaining.push(...group);
  }
  
  return { resolved, remaining };
}
```

## Testing Scenarios

### Test Case 1: Simple Two-Way Tie
```
Players A and B both have 5-2 record
A beat B in their match
Expected: A ranked higher via head-to-head
```

### Test Case 2: Three-Way Circular Tie
```
Players A, B, C all have 4-3 record
A beat B, B beat C, C beat A (circular)
Point differentials: A: +10, B: +5, C: -2
Expected: A > B > C via point differential
```

### Test Case 3: Complex Multi-Level Resolution
```
Players A, B, C, D all have 6-1 record
H2H: A beat all others (3-0)
      B, C, D each 1-2 in H2H group
Point differentials: B: +15, C: +15, D: +8
Total points: B: 77, C: 80
Expected: A > C > B > D
```

### Test Case 4: Complete Tie Through All Levels
```
Players A and B have identical:
- Wins: 5
- H2H: Never played each other
- Point Diff: +10
- Points For: 66
- Points Against: 56
Expected: Stable sort by player ID
```

## Performance Considerations

1. **Pre-calculate Statistics**: Calculate all stats once before sorting
2. **Early Exit**: Stop processing when all ties resolved
3. **Cache H2H Results**: Store head-to-head matrix for multiple queries
4. **Indexed Lookups**: Use Maps instead of array searches

## UI Display Requirements

1. **Visual Indicators**: Show which tiebreaker determined final position
2. **Tied Groups**: Visually group players who were initially tied
3. **Tiebreaker Details**: Expandable section showing all tiebreaker values
4. **Real-time Updates**: Recalculate immediately when scores entered

## Example Output Display

```
Rank | Player   | W-L  | PD   | PF  | PA  | Tiebreaker
-----|----------|------|------|-----|-----|------------
1    | Alice    | 7-0  | +45  | 77  | 32  | -
2    | Bob      | 5-2  | +20  | 66  | 46  | -
3    | Carol    | 5-2  | +18  | 65  | 47  | Point Diff
4    | David    | 5-2  | +15  | 70  | 55  | Point Diff
5    | Eve      | 3-4  | -5   | 55  | 60  | -
```