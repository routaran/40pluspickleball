# Partnership Optimization Algorithm

## Overview

The partnership optimization system ensures players partner with different people throughout the tournament while maintaining fairness and variety. This algorithm works in conjunction with the Modified Berger Tables to create an optimal social experience.

## Core Objectives

1. **Partnership Variety**: Minimize repeated partnerships
2. **Opponent Diversity**: Minimize repeated opponent matchups  
3. **Fair Distribution**: Ensure all players get variety
4. **Performance**: Execute efficiently for real-time generation
5. **Flexibility**: Handle player departures and mid-event joins

## Algorithm Architecture

### Data Structures

```typescript
interface PartnershipTracker {
  // Track all partnerships in event
  partnerships: Map<string, Set<string>>; // playerId -> Set of partner IDs
  
  // Track all opponent relationships
  opponents: Map<string, Set<string>>; // playerId -> Set of opponent IDs
  
  // Count frequencies
  partnershipCounts: Map<string, number>; // "playerId1-playerId2" -> count
  opponentCounts: Map<string, number>; // "playerId1-opponentId" -> count
  
  // Round history
  roundHistory: RoundPairings[];
}

interface RoundPairings {
  roundNumber: number;
  matches: MatchPairing[];
}

interface MatchPairing {
  team1: [string, string]; // [player1Id, player2Id]
  team2: [string, string]; // [player3Id, player4Id]
  court: number;
}

interface OptimizationScore {
  partnershipPenalty: number;
  opponentPenalty: number;
  totalScore: number;
  explanation: string[];
}
```

### Scoring System

The scoring system penalizes repeated relationships to encourage variety:

```typescript
const SCORING_WEIGHTS = {
  REPEATED_PARTNERSHIP: -10,  // Heavy penalty for same partnership
  REPEATED_OPPONENT: -5,      // Lighter penalty for same opponents
  NEW_PARTNERSHIP: 2,         // Small bonus for new partnership
  NEW_OPPONENT: 1,            // Small bonus for new opponent
  PERFECT_NOVELTY: 5          // Bonus when all relationships are new
};

function scorePairing(
  match: MatchPairing, 
  tracker: PartnershipTracker
): OptimizationScore {
  let score = 0;
  const explanation: string[] = [];
  
  // Check partnerships within teams
  const team1Key = createPartnershipKey(match.team1[0], match.team1[1]);
  const team2Key = createPartnershipKey(match.team2[0], match.team2[1]);
  
  // Partnership penalties/bonuses
  const team1Count = tracker.partnershipCounts.get(team1Key) || 0;
  const team2Count = tracker.partnershipCounts.get(team2Key) || 0;
  
  if (team1Count > 0) {
    score += SCORING_WEIGHTS.REPEATED_PARTNERSHIP;
    explanation.push(`Team 1 partnership repeated ${team1Count} times`);
  } else {
    score += SCORING_WEIGHTS.NEW_PARTNERSHIP;
    explanation.push('Team 1 has new partnership');
  }
  
  if (team2Count > 0) {
    score += SCORING_WEIGHTS.REPEATED_PARTNERSHIP;
    explanation.push(`Team 2 partnership repeated ${team2Count} times`);
  } else {
    score += SCORING_WEIGHTS.NEW_PARTNERSHIP;
    explanation.push('Team 2 has new partnership');
  }
  
  // Check opponent relationships (all cross-team pairs)
  let opponentPenalty = 0;
  const allOpponentPairs = [
    [match.team1[0], match.team2[0]], [match.team1[0], match.team2[1]],
    [match.team1[1], match.team2[0]], [match.team1[1], match.team2[1]]
  ];
  
  for (const [p1, p2] of allOpponentPairs) {
    const opponentKey = createOpponentKey(p1, p2);
    const opponentCount = tracker.opponentCounts.get(opponentKey) || 0;
    
    if (opponentCount > 0) {
      opponentPenalty += SCORING_WEIGHTS.REPEATED_OPPONENT;
      explanation.push(`${p1}-${p2} faced each other ${opponentCount} times`);
    } else {
      score += SCORING_WEIGHTS.NEW_OPPONENT;
    }
  }
  
  score += opponentPenalty;
  
  // Perfect novelty bonus
  if (team1Count === 0 && team2Count === 0 && opponentPenalty === 0) {
    score += SCORING_WEIGHTS.PERFECT_NOVELTY;
    explanation.push('Perfect novelty: all relationships are new');
  }
  
  return {
    partnershipPenalty: team1Count > 0 || team2Count > 0 ? 
      SCORING_WEIGHTS.REPEATED_PARTNERSHIP : 0,
    opponentPenalty,
    totalScore: score,
    explanation
  };
}
```

## Optimization Process

### Phase 1: Generate Initial Pairings

```typescript
function generateOptimizedRound(
  players: string[],
  tracker: PartnershipTracker,
  roundNumber: number
): MatchPairing[] {
  
  // Step 1: Get baseline pairings from Berger algorithm
  const bergerPairings = generateBergerRound(players, roundNumber);
  
  // Step 2: Apply optimization
  const optimizedPairings = optimizePairings(bergerPairings, tracker);
  
  // Step 3: Update tracker
  updateTracker(optimizedPairings, tracker);
  
  return optimizedPairings;
}
```

### Phase 2: Local Optimization

```typescript
function optimizePairings(
  initialPairings: MatchPairing[],
  tracker: PartnershipTracker,
  maxIterations: number = 100
): MatchPairing[] {
  
  let currentPairings = [...initialPairings];
  let bestPairings = [...currentPairings];
  let bestScore = calculateTotalScore(currentPairings, tracker);
  
  for (let iteration = 0; iteration < maxIterations; iteration++) {
    // Generate alternative pairings through swaps
    const alternatives = generateAlternatives(currentPairings);
    
    for (const alternative of alternatives) {
      const score = calculateTotalScore(alternative, tracker);
      
      if (score > bestScore) {
        bestScore = score;
        bestPairings = [...alternative];
      }
    }
    
    // Early exit if perfect score achieved
    if (bestScore >= getMaxPossibleScore(currentPairings.length)) {
      break;
    }
    
    currentPairings = bestPairings;
  }
  
  return bestPairings;
}
```

### Phase 3: Alternative Generation

```typescript
function generateAlternatives(pairings: MatchPairing[]): MatchPairing[][] {
  const alternatives: MatchPairing[][] = [];
  
  // Strategy 1: Swap partnerships within matches
  for (let i = 0; i < pairings.length; i++) {
    const swapped = swapPartnershipsInMatch(pairings, i);
    if (swapped) alternatives.push(swapped);
  }
  
  // Strategy 2: Swap players between matches
  for (let i = 0; i < pairings.length; i++) {
    for (let j = i + 1; j < pairings.length; j++) {
      const swapped = swapPlayersBetweenMatches(pairings, i, j);
      if (swapped.length > 0) alternatives.push(...swapped);
    }
  }
  
  // Strategy 3: Rotate players across multiple matches
  if (pairings.length >= 3) {
    const rotated = rotatePlayersAcrossMatches(pairings);
    if (rotated) alternatives.push(rotated);
  }
  
  return alternatives;
}

function swapPartnershipsInMatch(
  pairings: MatchPairing[],
  matchIndex: number
): MatchPairing[] | null {
  
  const modified = [...pairings];
  const match = modified[matchIndex];
  
  // Try swapping: A+B vs C+D → A+C vs B+D
  const alternative1: MatchPairing = {
    ...match,
    team1: [match.team1[0], match.team2[0]],
    team2: [match.team1[1], match.team2[1]]
  };
  
  // Try swapping: A+B vs C+D → A+D vs B+C  
  const alternative2: MatchPairing = {
    ...match,
    team1: [match.team1[0], match.team2[1]],
    team2: [match.team1[1], match.team2[0]]
  };
  
  // Return the better alternative
  modified[matchIndex] = alternative1;
  return modified;
}
```

## Handling Special Cases

### Mid-Event Player Departure

```typescript
function handlePlayerDeparture(
  playerId: string,
  tracker: PartnershipTracker,
  remainingRounds: RoundPairings[]
): PartnershipTracker {
  
  // Remove player from all future pairings
  const updatedRounds = remainingRounds.map(round => ({
    ...round,
    matches: round.matches.filter(match => 
      !matchIncludesPlayer(match, playerId)
    )
  }));
  
  // Preserve completed partnership/opponent history
  const updatedTracker = { ...tracker };
  
  // Don't remove historical data - it affects fairness for remaining players
  // Only update future round generation to exclude departed player
  
  return updatedTracker;
}
```

### Mid-Event Player Addition

```typescript
function handlePlayerAddition(
  newPlayerId: string,
  tracker: PartnershipTracker,
  currentRound: number
): PartnershipTracker {
  
  // Initialize empty history for new player
  tracker.partnerships.set(newPlayerId, new Set());
  tracker.opponents.set(newPlayerId, new Set());
  
  // New player gets priority for partnerships (all relationships are new)
  // This is handled naturally by the scoring system
  
  return tracker;
}
```

## Performance Optimizations

### Caching and Memoization

```typescript
class OptimizationCache {
  private scoringCache = new Map<string, OptimizationScore>();
  private alternativeCache = new Map<string, MatchPairing[][]>();
  
  getScore(pairingKey: string): OptimizationScore | null {
    return this.scoringCache.get(pairingKey) || null;
  }
  
  setScore(pairingKey: string, score: OptimizationScore): void {
    // Limit cache size
    if (this.scoringCache.size > 1000) {
      const firstKey = this.scoringCache.keys().next().value;
      this.scoringCache.delete(firstKey);
    }
    
    this.scoringCache.set(pairingKey, score);
  }
  
  private generatePairingKey(pairing: MatchPairing): string {
    // Create deterministic key for caching
    const team1 = [...pairing.team1].sort();
    const team2 = [...pairing.team2].sort();
    return `${team1.join('-')}vs${team2.join('-')}`;
  }
}
```

### Early Termination Strategies

```typescript
function shouldContinueOptimization(
  currentScore: number,
  maxPossibleScore: number,
  iteration: number,
  maxIterations: number
): boolean {
  
  // Perfect score achieved
  if (currentScore >= maxPossibleScore) return false;
  
  // Time limit exceeded (for real-time generation)
  if (iteration >= maxIterations) return false;
  
  // Diminishing returns (no improvement in last 10 iterations)
  // This would require tracking improvement history
  
  return true;
}
```

## Quality Metrics

### Partnership Variety Score

```typescript
function calculatePartnershipVariety(tracker: PartnershipTracker): number {
  let totalPairings = 0;
  let uniquePairings = 0;
  
  for (const [_, partners] of tracker.partnerships) {
    totalPairings += partners.size;
  }
  
  uniquePairings = tracker.partnershipCounts.size;
  
  // Higher is better (more unique partnerships)
  return uniquePairings / Math.max(totalPairings, 1);
}
```

### Opponent Diversity Score

```typescript
function calculateOpponentDiversity(tracker: PartnershipTracker): number {
  let totalOpponents = 0;
  let uniqueOpponents = 0;
  
  for (const [_, opponents] of tracker.opponents) {
    totalOpponents += opponents.size;
  }
  
  uniqueOpponents = tracker.opponentCounts.size;
  
  return uniqueOpponents / Math.max(totalOpponents, 1);
}
```

### Overall Fairness Score

```typescript
function calculateFairnessScore(
  tracker: PartnershipTracker, 
  players: string[]
): number {
  const partnershipVariety = calculatePartnershipVariety(tracker);
  const opponentDiversity = calculateOpponentDiversity(tracker);
  
  // Check distribution balance
  const partnershipCounts = players.map(p => 
    tracker.partnerships.get(p)?.size || 0
  );
  
  const mean = partnershipCounts.reduce((a, b) => a + b) / partnershipCounts.length;
  const variance = partnershipCounts.reduce((acc, count) => 
    acc + Math.pow(count - mean, 2), 0
  ) / partnershipCounts.length;
  
  const distributionBalance = 1 / (1 + variance); // Lower variance = higher score
  
  // Weighted combination
  return (
    partnershipVariety * 0.4 +
    opponentDiversity * 0.3 +
    distributionBalance * 0.3
  );
}
```

## Testing and Validation

### Unit Tests

1. **Scoring Function**
   ```typescript
   test('scores repeated partnerships correctly', () => {
     const tracker = new PartnershipTracker();
     tracker.partnershipCounts.set('A-B', 1);
     
     const match: MatchPairing = {
       team1: ['A', 'B'],
       team2: ['C', 'D'],
       court: 1
     };
     
     const score = scorePairing(match, tracker);
     expect(score.totalScore).toBeLessThan(0);
     expect(score.partnershipPenalty).toBe(SCORING_WEIGHTS.REPEATED_PARTNERSHIP);
   });
   ```

2. **Optimization Process**
   ```typescript
   test('improves pairing quality through optimization', () => {
     const initialPairings = generateWorstCasePairings();
     const tracker = createPreloadedTracker();
     
     const optimized = optimizePairings(initialPairings, tracker);
     const initialScore = calculateTotalScore(initialPairings, tracker);
     const optimizedScore = calculateTotalScore(optimized, tracker);
     
     expect(optimizedScore).toBeGreaterThanOrEqual(initialScore);
   });
   ```

### Integration Tests

1. **Full Tournament Simulation**
   - Generate complete 8-player tournament
   - Verify no partnerships repeated until mathematically necessary
   - Confirm opponent variety maintained

2. **Performance Benchmarks**
   - 16 players, 15 rounds: < 100ms total
   - 32 players, 31 rounds: < 500ms total
   - Memory usage < 10MB for largest tournaments

## Implementation Notes

1. **Integration with Berger Algorithm**: The optimization runs after Berger generation, improving the baseline pairings rather than replacing them entirely.

2. **Real-time Constraints**: For courtside use, optimization must complete quickly. Use early termination and caching strategies.

3. **User Feedback**: Display partnership variety metrics to organizers so they can see the quality of generated pairings.

4. **Configuration**: Allow organizers to adjust scoring weights if they prefer different optimization priorities.

5. **Debugging**: Provide detailed scoring explanations for troubleshooting pairing decisions.