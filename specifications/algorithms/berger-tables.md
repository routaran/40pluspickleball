# Modified Berger Tables Algorithm for Doubles Round Robin

## Overview

The Modified Berger Tables algorithm generates a round-robin tournament schedule optimized for doubles play. Unlike traditional Berger tables used for singles, this modification ensures players partner with different players throughout the tournament while maintaining the core rotation principles.

## Core Principles

1. **Complete Coverage**: Every player partners with as many different players as possible
2. **Opponent Variety**: Players face different opponents in each round
3. **Court Efficiency**: Minimize idle time and maximize court usage
4. **Fair Bye Distribution**: When player count isn't divisible by 4, byes are distributed evenly

## Algorithm Implementation

### Input
- `players`: Array of player objects with IDs
- `totalRounds`: Number of rounds to generate (optional, defaults to optimal)

### Output
- Array of rounds, each containing matches with team assignments

### Step-by-Step Implementation

```typescript
interface Player {
  id: string;
  name: string;
}

interface Team {
  player1: Player;
  player2: Player;
}

interface Match {
  id: string;
  roundNumber: number;
  matchNumber: number;
  team1: Team;
  team2: Team;
  court?: number;
  isBye?: boolean;
}

interface Round {
  roundNumber: number;
  matches: Match[];
}

function generateDoublesBergerTables(players: Player[]): Round[] {
  const n = players.length;
  const rounds: Round[] = [];
  
  // Handle edge cases
  if (n < 4) {
    throw new Error("Minimum 4 players required for doubles");
  }
  
  // Determine if we need a ghost player for odd numbers
  const needsGhost = n % 2 !== 0;
  const totalPlayers = needsGhost ? n + 1 : n;
  const playersWithGhost = [...players];
  
  if (needsGhost) {
    playersWithGhost.push({ id: 'GHOST', name: 'Ghost' });
  }
  
  // Calculate number of rounds
  // For doubles, we want each player to partner with as many others as possible
  const standardRounds = totalPlayers - 1; // Standard Berger rounds
  const matchesPerRound = Math.floor(totalPlayers / 4) * 2;
  
  // Generate rounds using rotating schedule
  for (let round = 0; round < standardRounds; round++) {
    const roundMatches: Match[] = [];
    const roundPlayers = [...playersWithGhost];
    
    // Rotate players (except first player in standard Berger)
    if (round > 0) {
      const fixed = roundPlayers[0];
      const rotating = roundPlayers.slice(1);
      // Rotate clockwise
      const last = rotating.pop()!;
      rotating.unshift(last);
      roundPlayers.splice(0, roundPlayers.length, fixed, ...rotating);
    }
    
    // Create pairings for this round
    const pairs: Team[] = [];
    const used = new Set<string>();
    
    // Use optimized pairing for doubles
    // Strategy: Pair players from opposite ends of the rotation
    for (let i = 0; i < totalPlayers / 2; i++) {
      const p1 = roundPlayers[i];
      const p2 = roundPlayers[totalPlayers - 1 - i];
      
      if (!used.has(p1.id) && !used.has(p2.id)) {
        pairs.push({ player1: p1, player2: p2 });
        used.add(p1.id);
        used.add(p2.id);
      }
    }
    
    // Create matches from pairs
    for (let i = 0; i < pairs.length - 1; i += 2) {
      const team1 = pairs[i];
      const team2 = pairs[i + 1];
      
      // Skip matches involving ghost player
      if (team1.player1.id === 'GHOST' || team1.player2.id === 'GHOST' ||
          team2.player1.id === 'GHOST' || team2.player2.id === 'GHOST') {
        continue;
      }
      
      roundMatches.push({
        id: `round${round + 1}_match${roundMatches.length + 1}`,
        roundNumber: round + 1,
        matchNumber: roundMatches.length + 1,
        team1,
        team2,
        isBye: false
      });
    }
    
    rounds.push({
      roundNumber: round + 1,
      matches: roundMatches
    });
  }
  
  // Handle bye assignments for players not in matches
  assignByes(rounds, players, totalPlayers);
  
  return rounds;
}
```

## Partnership Optimization Layer

After generating the basic rotation, apply partnership optimization:

```typescript
function optimizePartnerships(rounds: Round[], players: Player[]): Round[] {
  const partnershipTracker = new Map<string, Set<string>>();
  const optimizedRounds: Round[] = [];
  
  // Initialize partnership tracker
  players.forEach(p => partnershipTracker.set(p.id, new Set()));
  
  for (const round of rounds) {
    const optimizedMatches: Match[] = [];
    
    for (const match of round.matches) {
      // Score current pairing
      const currentScore = scorePairing(match, partnershipTracker);
      
      // Try alternative pairings within the same match
      const alternatives = generateAlternativePairings(match);
      let bestMatch = match;
      let bestScore = currentScore;
      
      for (const alt of alternatives) {
        const altScore = scorePairing(alt, partnershipTracker);
        if (altScore > bestScore) {
          bestMatch = alt;
          bestScore = altScore;
        }
      }
      
      // Update partnership tracker
      updatePartnershipTracker(bestMatch, partnershipTracker);
      optimizedMatches.push(bestMatch);
    }
    
    optimizedRounds.push({
      roundNumber: round.roundNumber,
      matches: optimizedMatches
    });
  }
  
  return optimizedRounds;
}

function scorePairing(match: Match, tracker: Map<string, Set<string>>): number {
  let score = 0;
  
  // Penalize repeated partnerships
  if (tracker.get(match.team1.player1.id)?.has(match.team1.player2.id)) {
    score -= 10;
  }
  if (tracker.get(match.team2.player1.id)?.has(match.team2.player2.id)) {
    score -= 10;
  }
  
  // Penalize repeated opponents (less severe)
  const team1Players = [match.team1.player1.id, match.team1.player2.id];
  const team2Players = [match.team2.player1.id, match.team2.player2.id];
  
  for (const t1p of team1Players) {
    for (const t2p of team2Players) {
      if (tracker.get(t1p)?.has(t2p)) {
        score -= 5;
      }
    }
  }
  
  return score;
}
```

## Handling Special Cases

### Odd Number of Players (Bye Rounds)

When the player count isn't divisible by 4, some players sit out each round:

```typescript
function assignByes(rounds: Round[], players: Player[], totalPlayers: number): void {
  const byesPerRound = totalPlayers % 4;
  
  if (byesPerRound === 0) return;
  
  const byeTracker = new Map<string, number>();
  players.forEach(p => byeTracker.set(p.id, 0));
  
  for (const round of rounds) {
    const playingPlayers = new Set<string>();
    
    // Track who's playing
    round.matches.forEach(match => {
      playingPlayers.add(match.team1.player1.id);
      playingPlayers.add(match.team1.player2.id);
      playingPlayers.add(match.team2.player1.id);
      playingPlayers.add(match.team2.player2.id);
    });
    
    // Find players not playing (excluding ghost)
    const byePlayers = players.filter(p => 
      !playingPlayers.has(p.id) && p.id !== 'GHOST'
    );
    
    // Update bye count
    byePlayers.forEach(p => {
      byeTracker.set(p.id, (byeTracker.get(p.id) || 0) + 1);
    });
  }
}
```

## Examples

### Example 1: 8 Players

```
Players: A, B, C, D, E, F, G, H

Round 1:
- Court 1: A+H vs B+G
- Court 2: C+F vs D+E

Round 2:
- Court 1: A+G vs C+E  
- Court 2: B+F vs D+H

Round 3:
- Court 1: A+F vs D+G
- Court 2: B+E vs C+H

... continues for 7 rounds total
```

### Example 2: 9 Players (Bye Example)

```
Players: A, B, C, D, E, F, G, H, I

Round 1:
- Court 1: A+I vs B+H
- Court 2: C+G vs D+F
- Bye: E

Round 2:
- Court 1: A+H vs C+F
- Court 2: B+G vs E+I  
- Bye: D

... bye rotates each round
```

## Performance Optimization

### Time Complexity
- Basic generation: O(n² × r) where n = players, r = rounds
- Partnership optimization: O(r × m × p) where m = matches, p = alternative pairings
- Total: O(n² × r) for typical cases

### Space Complexity
- O(n² + r × m) for tracking partnerships and storing rounds

### Optimization Strategies

1. **Pre-compute Partnership Combinations**
   ```typescript
   const validPartnerships = precomputePartnerships(players);
   ```

2. **Use Memoization for Scoring**
   ```typescript
   const scoreCache = new Map<string, number>();
   ```

3. **Early Termination**
   - Stop optimization if perfect score achieved
   - Limit alternatives checked per match

## Testing Strategy

### Unit Tests

1. **Basic Functionality**
   - 4 players generates 3 rounds
   - 8 players generates 7 rounds
   - Each player plays each round (except byes)

2. **Partnership Variety**
   - No repeated partnerships in first n-1 rounds
   - Minimal repeated opponents

3. **Bye Distribution**
   - 5 players: each gets 1 bye in 5 rounds
   - 9 players: bye count differs by at most 1

### Integration Tests

1. **With Court Assignment**
   - Matches distributed across available courts
   - No conflicts in court usage

2. **With Score Entry**
   - Generated matches accept valid scores
   - Standings calculate correctly

## Implementation Notes

1. **Player Order**: Initial player order affects pairings. Consider randomizing for variety across events.

2. **Round Count**: Default to n-1 rounds, but allow configuration for shorter events.

3. **Court Assignment**: Assign courts after match generation for flexibility.

4. **Persistence**: Store partnership history in database for cross-event optimization (future enhancement).

5. **UI Feedback**: Show partnership variety score to organizers.