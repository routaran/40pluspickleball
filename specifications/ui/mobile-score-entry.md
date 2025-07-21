# Mobile Score Entry UI/UX Specification

## Overview

The score entry interface is designed for organizers to quickly and accurately enter match scores from their mobile devices while standing courtside. The interface prioritizes large touch targets, minimal required precision, and efficient workflows.

## Design Principles

1. **One-Thumb Operation**: All primary actions accessible with single thumb
2. **Large Touch Targets**: Minimum 44px height, 48px preferred
3. **Clear Visual Feedback**: Immediate response to all interactions
4. **Error Prevention**: Smart defaults and validation
5. **Quick Entry**: Minimize taps required per score

## Screen Layouts

### Portrait Mode (Primary)

```
┌─────────────────────────────────┐
│       Round 3 - Match 2         │ <- Sticky header
│        Court 1                  │
├─────────────────────────────────┤
│                                 │
│  Team 1                         │
│  ┌───────────────────────────┐  │
│  │  Alice Anderson &          │  │ <- Team display
│  │  Bob Brown                 │  │    (18px font)
│  └───────────────────────────┘  │
│                                 │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │  9  │  │ 11  │  │ 15  │     │ <- Quick presets
│  └─────┘  └─────┘  └─────┘     │    (48px height)
│                                 │
│  ┌───────────────────────────┐  │
│  │           11              │  │ <- Score input
│  └───────────────────────────┘  │    (56px height)
│                                 │    (32px font)
│         VS                      │
│                                 │
│  Team 2                         │
│  ┌───────────────────────────┐  │
│  │  Carol Chen &              │  │
│  │  David Davis               │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │  9  │  │ 11  │  │ 15  │     │
│  └─────┘  └─────┘  └─────┘     │
│                                 │
│  ┌───────────────────────────┐  │
│  │            9               │  │
│  └───────────────────────────┘  │
│                                 │
├─────────────────────────────────┤
│                                 │
│  ┌───────────────────────────┐  │
│  │      SAVE SCORE           │  │ <- Primary action
│  └───────────────────────────┘  │    (56px height)
│                                 │    Green when valid
│  ┌────────┐      ┌──────────┐  │
│  │ CANCEL │      │   NEXT   │  │ <- Secondary actions
│  └────────┘      └──────────┘  │    (48px height)
│                                 │
└─────────────────────────────────┘
```

### Landscape Mode (Alternative)

```
┌─────────────────────────────────────────────────────┐
│            Round 3 - Match 2 - Court 1              │
├─────────────────────────────────────────────────────┤
│                    │                                │
│   Team 1           │            Team 2              │
│   Alice & Bob      │            Carol & David       │
│                    │                                │
│   ┌─────────────┐  │         ┌─────────────┐       │
│   │     11      │  │   VS    │      9      │       │
│   └─────────────┘  │         └─────────────┘       │
│                    │                                │
│  [9] [11] [15]     │         [9] [11] [15]         │
│                    │                                │
├─────────────────────────────────────────────────────┤
│  [CANCEL]          [SAVE SCORE]          [NEXT]     │
└─────────────────────────────────────────────────────┘
```

## Interactive Elements

### Score Input Fields

**Behavior**:
- Numeric keyboard opens automatically
- Auto-advance to next field after 2 digits entered
- Clear button (X) appears when field has value
- Validation shows inline (red border for invalid)

**States**:
```
Empty: [ — ]
Focused: [ | ] (blinking cursor)
Filled: [ 11 ]
Invalid: [ 11 ] (red border if score invalid for format)
```

### Quick Score Presets

**Common Scores** (based on scoring format):
- 11 points, win by 2: [9] [11] [7]
- 15 points, win by 2: [13] [15] [11]
- Custom preset based on most common scores

**Behavior**:
- Tap preset to fill score field
- Preset buttons adapt to scoring format
- Most used scores appear first

### Save Score Button

**States**:
- Disabled (gray): When scores invalid or empty
- Enabled (green): When valid score entered
- Loading: Shows spinner during save
- Success: Brief checkmark animation

**Validation Rules**:
- One team must have winning score
- Scores must follow event's scoring format
- Both fields must have values

### Navigation

**Match Navigation**:
- Swipe left/right between matches in same round
- "Next" button advances to next unscored match
- Match counter shows position (2 of 8)

**Round Navigation**:
- Dropdown/select for jumping to specific round
- Visual indicator for current round progress

## Error Handling

### Validation Errors

```
┌─────────────────────────────────┐
│  ⚠️ Invalid Score               │
│  Win by 2 required (11-9 min)   │
│                                 │
│  [Got it]                       │
└─────────────────────────────────┘
```

### Network Errors

```
┌─────────────────────────────────┐
│  ❌ Connection Lost             │
│  Score saved locally            │
│                                 │
│  [Retry]     [Save for Later]  │
└─────────────────────────────────┘
```

## Gesture Support

1. **Swipe Navigation**:
   - Left/Right: Between matches
   - Up/Down: Scroll through round

2. **Tap Targets**:
   - All buttons: 44px minimum
   - Score fields: 56px height
   - Adequate spacing between elements

3. **Long Press**:
   - Score field: Clear value
   - Team name: Show full names if truncated

## Loading States

### Initial Load
```
┌─────────────────────────────────┐
│                                 │
│         Loading matches...      │
│            ◐◓◑◒                 │
│                                 │
└─────────────────────────────────┘
```

### Saving Score
- Button shows spinner
- Inputs disabled during save
- Success feedback (green check)

## Accessibility

1. **Font Sizes**:
   - Minimum body: 16px
   - Player names: 18px
   - Score inputs: 32px
   - Headers: 20px

2. **Contrast**:
   - All text: WCAG AA compliant
   - Important buttons: High contrast
   - Error states: Not just color

3. **Touch Targets**:
   - Minimum: 44x44px
   - Preferred: 48x48px
   - Spacing: 8px between targets

## Offline Handling

### Queue System
```typescript
interface OfflineScore {
  matchId: string;
  team1Score: number;
  team2Score: number;
  timestamp: Date;
  synced: boolean;
}
```

### UI Indicators
- Offline badge in header
- Queue count if scores pending
- Auto-sync when connection restored

## Performance Optimizations

1. **Preload Next Match**: Load next match data in background
2. **Optimistic Updates**: Show success immediately, sync in background
3. **Minimal Re-renders**: Only update changed elements
4. **Touch Delay**: 0ms for all interactive elements

## Sample React Component Structure

```typescript
// ScoreEntryView.tsx
interface ScoreEntryViewProps {
  match: Match;
  onSave: (scores: Scores) => Promise<void>;
  onNext: () => void;
  onPrevious: () => void;
}

// Components hierarchy:
<ScoreEntryView>
  <MatchHeader />
  <TeamScoreInput team={1}>
    <TeamDisplay />
    <ScorePresets />
    <ScoreField />
  </TeamScoreInput>
  <TeamScoreInput team={2}>
    <TeamDisplay />
    <ScorePresets />
    <ScoreField />
  </TeamScoreInput>
  <ActionButtons>
    <CancelButton />
    <SaveButton />
    <NextButton />
  </ActionButtons>
</ScoreEntryView>
```

## CSS Styling Example

```css
/* Mobile-first approach */
.score-entry {
  padding: 16px;
  max-width: 100%;
}

.score-input {
  height: 56px;
  font-size: 32px;
  text-align: center;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  width: 100%;
  /* Remove default iOS styling */
  -webkit-appearance: none;
}

.score-input:focus {
  border-color: #2196F3;
  outline: none;
}

.score-preset {
  height: 48px;
  min-width: 64px;
  font-size: 18px;
  font-weight: 600;
  border-radius: 6px;
}

.save-button {
  height: 56px;
  font-size: 18px;
  font-weight: 700;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 8px;
  width: 100%;
}

.save-button:disabled {
  background: #CCCCCC;
  color: #666666;
}

/* Landscape adjustments */
@media (orientation: landscape) {
  .score-entry {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }
}

/* Larger devices */
@media (min-width: 768px) {
  .score-entry {
    max-width: 600px;
    margin: 0 auto;
  }
}
```

## Testing Checklist

- [ ] One-thumb operation verified
- [ ] All touch targets ≥ 44px
- [ ] Score validation works correctly
- [ ] Offline queue functions
- [ ] Landscape mode usable
- [ ] Quick presets save time
- [ ] Navigation between matches smooth
- [ ] Error messages clear
- [ ] Loading states present
- [ ] Success feedback visible