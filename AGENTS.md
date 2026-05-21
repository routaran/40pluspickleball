# 40+ Pickleball Round Robin - Refactoring & Migration Specification

This document provides a comprehensive functional, state, and algorithmic specification of the client-side Pickleball Round Robin Matchmaker application. It is designed to serve as a **regression-testing blueprint** and **durable reference guide** for refactoring the current single-file monolith (`index.html`) into a clean, modular, multi-file architecture with separated HTML, CSS, and JS.

> [!IMPORTANT]
> **CRITICAL REQUIREMENT: MOBILE-FIRST CELL PHONE OPTIMIZATION**
> This application is almost exclusively used via mobile web browsers on smartphones (e.g., by tournament coordinators holding their phones or with phones mounted directly on court posts).
> 
> Any refactoring **MUST** optimize all UI/UX elements for mobile display (~412px CSS width like Pixel 7):
> 1. **Zero Clipping & No Horizontal Scroll**: No layout elements, schedule tables, or control boxes may overflow the viewport. Column widths must adjust dynamically and wrap player names gracefully.
> 2. **Touch Target Size & Accessibility**: Interactive elements (skill selector dots, timer control buttons, dropdown selectors) must have generous touch targets to prevent accidental taps on small mobile screens.
> 3. **Critical Mobile Subsystems**:
>    - *Screen Wake Lock API*: Crucial to prevent phone screens from going to sleep while a match is in progress on a court post.
>    - *Synth Audio Alarm API*: Needs a loud, highly visible warning and clear audio synthesis so players can hear the round ending from across the courts.
> 4. **Print Media Optimizations**: While the view is screen-centric, triggering print emulation must comfortably scale the 7-round table to a single-page printable portrait view without buttons or timer UI.

---


## 1. Monolithic Directory Overview

Currently, the application contains:
*   [index.html](file:///home/rkalluri/Downloads/src/40pluspickleball/index.html) (1067 lines): Houses all CSS styles (`<style>`), structural markup (`<body>`), and all Vanilla JS code (`<script>`).
*   [404.html](file:///home/rkalluri/Downloads/src/40pluspickleball/404.html): A minimal single-page router fallback specifically for GitHub Pages SPA hosting.
*   `LICENSE`: MIT License.

---

## 2. Behavioral State Machine & DOM Views

The application transitions dynamically between two primary layout states, controlled via visibility classes on root wrappers:

```
+--------------------------------------+
|             SETUP VIEW               | <--- Initial State
|  - Court Inputs (IDs: court1, court2)|
|  - Mode Selector (Random / Balanced) |
|  - 8 Player Names + Skill Selectors  |
|  - "Generate Schedule" Button        |
+--------------------------------------+
                   |
             (generate())
                   v
+--------------------------------------+
|        PRINTABLE & TIMER VIEW        |
|  - Printable Match Table (#schedule) |
|  - Timer Panel (#timerSection)       |
|  - Audio Synth Alarm API             |
|  - Wake Lock API Controller          |
|  - "Back" / "Print" / "Reset"        |
+--------------------------------------+
                   |
               (goBack())
                   v
        (Restores SETUP VIEW)
```

### View Transition Logic
*   **Active Setup View (Screen-Only)**: The `#setup` div is visible (`display: ''`). The `#printable` div is hidden (`display: none`).
*   **Active Printable/Timer View**: The `#setup` div is hidden (`display: 'none'`). The `#printable` div is activated (`classList.add('active')`), which exposes the generated match schedule table and the round-progression timer controls.
*   **Media-Print Styles**: When `window.print()` is triggered, all elements marked with `.no-print` (including setup elements, buttons, and timer control panels) are hidden. The schedule table expands to a fixed letter size (`8.5" x 11"` with `0.5"` margins) optimizing readability for printouts.

---

## 3. Global Runtime State Model

The entire state of a tournament session is managed by 5 global variables. In a refactored codebase, these should be encapsulated into a unified state store or class (e.g., `TournamentState`).

| State Variable | Data Type | Default Value | Role & Description |
|---|---|---|---|
| `mode` | `String` | `'random'` | Current matchmaking engine setting. Either `'random'` or `'balanced'`. |
| `currentRound` | `Integer` | `0` | 0-indexed integer indicating the currently active round (ranges from `0` to `6`). |
| `totalRounds` | `Integer` | `7` | The constant length of the round-robin schedule (always 7 rounds for 8 players). |
| `roundsData` | `Array` | `[]` | 3D array storing the generated matchup schedule. Represented as: `[ Rounds [ Courts [ Matchup { team1: [p1, p2], team2: [p3, p4] } ] ] ]`. |
| `courtsData` | `Array` | `[]` | Array of two strings indicating the court identifier labels: `[court1Label, court2Label]`. |

---

## 4. Matchmaking Algorithms & Algorithmic DAG

The application generates an optimal tournament schedule for **8 players, across 2 courts, over 7 rounds**.

```
                        [buildSchedule()]
                               |
            ---------------------------------------
           |                                       |
     [Fully Random]                        [Skill Balanced]
           |                                       |
    (Pure Shuffle)                        (Constraint Solver)
           |                                       |
     Assemble Round                  Evaluate 1500 Combinations
                                                   |
                                     (Compute Penalty Score per combo)
                                                   |
                                        Satisfies Core Rules?
                                        /                  \
                                     (Yes)                 (No)
                                      /                      \
                             [Tier 1: Best Score]     [Tier 2: G/G Only]
                                                               \
                                                               (No)
                                                                 \
                                                      [Tier 3: G-Partition / Pure Random]
```

### Core Matchmaking Constraints (Skill Balanced Mode)
In Skill Balanced Mode, each player is assigned one of four skill tiers represented by colors:
*   **Advanced** (Green) = `4 pts`
*   **Upper Intermediate** (Blue) = `3 pts`
*   **Intermediate** (Orange) = `2 pts`
*   **Beginner** (Red) = `1 pt`

The scheduler solves for the following constraints to ensure fair play:
1.  **Green-Pair Rule (Advanced Matchups)**:
    Teams where both players are Green ("Advanced") must ONLY play against other teams where both players are Green. If any player on either team is Green, both teams must be all-green. G/G pairs never play mixed teams.
2.  **Strength Gap Rule**:
    The combined skill points of Team 1 and Team 2 must be balanced. The absolute difference between their total skill points must not exceed `2`:
    $$\left|(pts(Player_{1a}) + pts(Player_{1b})) - (pts(Player_{2a}) + pts(Player_{2b}))\right| \le 2$$
3.  **Weakest-Player Rule**:
    To prevent a beginner from being targeted by highly skilled opponents (e.g. Green + Red vs Green + Blue), the weaker players on opposing teams must be within 1 tier of each other:
    $$\left|\min(pts(Player_{1a}), pts(Player_{1b})) - \min(pts(Player_{2a}), pts(Player_{2b}))\right| \le 1$$
4.  **Repeat Minimization Scoring**:
    The engine runs up to **1500 shuffle attempts** per round to find the candidate with the absolute minimum duplicate penalty:
    *   `+10` points for each time a pair has partnered in previous rounds.
    *   `+1` point for each time opponents have faced each other before.
    *   `+1000` points if a G/G vs G/G matchup has already occurred (to prevent repetitive Advanced matches).
    *   `-100` points for the first occurrence of a G/G vs G/G matchup to favor it.
5.  **Multi-Tier Resolution Fallbacks**:
    *   **Tier 1**: Select the attempt with the lowest penalty score that satisfies all constraints (Rules 1-3).
    *   **Tier 2**: If no combination satisfies Tier 1 after 1500 attempts, relax rules 2 and 3. Generate 1500 new attempts enforcing **only** the Green-Pair Rule (G/G vs G/G) and pick the first successful match.
    *   **Tier 3 (Green Partition Fallback)**: If Tier 2 still fails:
        *   If there are exactly 4 green players, group the 4 greens on Court 1 (G/G vs G/G) and the 4 non-greens on Court 2.
        *   Otherwise, bypass balanced scheduling entirely for that round and generate a purely random setup.
6.  **Court Priority / Strength Sorting**:
    After scheduling a round's matchups, court locations are dynamically ordered by strength (sum of all 4 court player skill points):
    *   For the **first 4 rounds**, the stronger matchup is forced on Court 1.
    *   For **rounds 5 to 7**, court assignments alternate (weaker on Court 1, stronger on Court 2) to ensure a balanced court rotation.

---

## 5. Subsystem Specifications

### A. Local Storage Persistence (`localStorage`)
*   **Key**: `pickleball-rr-setup-v1`
*   **State Saved**: A single JSON string representing the following object:
    ```javascript
    {
      courts: [court1Label, court2Label],
      players: [p1, p2, p3, p4, p5, p6, p7, p8],
      skills: [sk1, sk2, sk3, sk4, sk5, sk6, sk7, sk8],
      mode: 'random' | 'balanced',
      timerMin: String,
      timerSec: String
    }
    ```
*   **Triggers**: Autosaves instantly on any `input` event inside the `#setup` div, `#timerMin` inputs, or `#timerSec` inputs. Auto-loaded once on application launch.

### B. Round Progression Timer & Row Highlighting
*   **Display Logic**: Controls starting, pausing, and resetting the countdown. Remaining time is dynamically calculated and rendered in `M:SS` format.
*   **Row DOM Highlights**:
    Rows are styled dynamically using standard class mappings depending on the state of `currentRound`:
    *   `i < currentRound`: Added class `round-done` (greenish background, reduced opacity, compact padding).
    *   `i === currentRound`: Added class `round-active` (yellow highlight, bold text, elevated borders).
    *   `i > currentRound`: Added class `round-upcoming` (faded opacity, compact layout).
*   **Auto-Scroll**: On round transitions, the active row is smoothly centered in the viewport via:
    ```javascript
    activeRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
    ```

### C. Zero-Dependency Synth Audio Alarm (Web Audio API)
*   **Frequency**: `1000Hz` square wave, creating a high-visibility, piercing tone.
*   **Alarm Loop Pattern**: 3 rapid beeps (each beep plays for `0.2` seconds, spaced by `0.15` seconds of silence) repeated in cycles every `1.5` seconds.
*   **State Control**: Alarm is initiated inside `timerStart()` when `timerRemaining` drops to 0. It is cleared instantly using `stopAlarm()`, which stops active oscillators, clears the interval loop, and closes the active `AudioContext` to free browser resources.

### D. Screen Wake Lock API
*   **Objective**: Prevents screens on mobile devices (e.g. phones mounted on court posts) from going to sleep while a match timer is running.
*   **Lifecycle**:
    *   `enableWakeLock()`: Sets indicator `wantWakeLock = true` and requests a wake lock.
    *   `releaseWakeLock()`: Resets indicator `wantWakeLock = false` and releases the wake lock.
    *   **Acquisition**: Triggers whenever the timer starts running (`timerRunning = true`).
    *   **Release**: Triggers when the timer is paused, reset, ended, or when the tab loses visibility.
    *   **Visibility Change**: Listens to browser page visibility events. If the tab becomes active again (`visibilityState === 'visible'`) and the timer was running, it automatically re-acquires the wake lock.

---

## 6. Proposed Target Modular Architecture

When refactoring the monolith, split the code according to this structured modular architecture:

```
/ (Project Root)
├── index.html                  # Minimal markup skeleton, script & style links
├── style.css                   # Refactored design system (Layout, Print, Mobile)
└── js/
    ├── app.js                  # Main entry point (initializes listeners & loads config)
    ├── state.js                # State Store Class (encapsulates global variables)
    ├── scheduler.js            # Matchmaking Engine (buildSchedule & constraints logic)
    ├── ui.js                   # DOM manager (render functions, view toggles, scroll)
    ├── timer.js                # Timer & Wake Lock controller (setInterval & Wake Lock)
    └── audio.js                # Audio Synth Alarm module (Web Audio API context)
```

---

## 7. Migration & Regression Checklist

Use this checklist during your refactoring to guarantee zero functional regressions:

- [ ] **Setup Persistence**: Verify typing a player name or court number automatically saves to `localStorage` and loads back correctly after a full page refresh.
- [ ] **Skill Cycling**: In "Skill Balanced" mode, verify clicking a player's skill circle cycles colors through Green -> Blue -> Orange -> Red and saves to local storage. Verify skill circles are hidden when switching to "Fully Random" mode.
- [ ] **Schedule Generation**: Ensure clicking "Generate Schedule" populates a 7-round table showing all 8 players rotated properly.
- [ ] **Green-Pair Separation**: Set 4 players as Green and 4 as Red. Generate balanced schedules and verify Green pairs *never* face a team with a Red player (G/G vs G/G is strictly on Court 1).
- [ ] **Timer Start/Pause/Reset**: Verify the timer starts at the user's input minutes/seconds, counts down accurately, pauses when clicked, resumes smoothly, and resets back to inputs when "Reset" is pressed.
- [ ] **Auto-Scroll Behavior**: Verify that when a round ends, the subsequent round gets highlighted and the page smoothly scrolls to place the active round row in the center of the screen.
- [ ] **Audio Alarm**: Let the timer count down to zero. Verify the alarm starts a repeating pattern of 3 piercing beeps. Verify that clicking "Reset", "Start Round", or "End Round" stops the beep loop immediately.
- [ ] **Wake Lock**: Verify no JavaScript errors are thrown on visibility change or wake-lock acquisition, even on browsers that do not support `navigator.wakeLock` (ensure graceful try-catch fallback).
- [ ] **Mobile Layout**: Emulate a screen width of `412px` (Pixel 7) in DevTools. Ensure table columns do not clip and buttons wrap comfortably without overlaps.
- [ ] **Print Layout**: Run `window.print()` or trigger print emulation. Ensure the schedule page expands to fill the page, table rows are fully visible with white backgrounds, and all control buttons and headers are hidden.
