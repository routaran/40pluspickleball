# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file vanilla JS web app for running pickleball round-robin tournaments. Deployed as a static site on GitHub Pages (`gh-pages` branch). No build step, no dependencies, no framework.

**Files:**
- `index.html` — the entire app: all CSS, HTML markup, and JS in one file
- `404.html` — SPA fallback for GitHub Pages routing
- `AGENTS.md` — detailed spec/migration blueprint (read this before any refactoring)

## Development

Open `index.html` directly in a browser — no server needed. For mobile testing, serve locally:

```bash
python3 -m http.server 8080
# then open http://localhost:8080 on a phone or DevTools mobile emulation (320–430px range)
```

There are no tests, no linter config, and no build pipeline.

## Architecture

**Multi-view state machine** toggled by JS:
- **Setup View** (`#setup`): court numbers, mode selector, 8 player names + skill dots → `generate()`
- **Schedule/Timer View** (`#printable`): round match table + countdown timer
- **Scoreboard View** (`#scoreboard`): ranked standings table; accessible mid-tournament and prominently surfaced on completion

**Key globals** (in `<script>` at bottom of `index.html`):
- `mode` — `'random'` | `'balanced'`
- `currentRound` / `totalRounds` — round progression (0-indexed); `totalRounds` can exceed 7 when bonus rounds are added
- `roundsData` — `Array` of rounds; each round is an array of court matchups `{ team1: [name, name], team2: [name, name] }`. Regular rounds have length 2; a 1-court bonus round has length 1. The `tbody`/standings code iterates `round.forEach((m, c) => ...)` and does not assume 2 courts, though `render()`'s `<thead>` always emits 2 column headers — a 1-court round gets `—` in the second cell.
- `scoresData` — parallel to `roundsData`. A scored court is `scoresData[r][c] = { team1: int, team2: int }`; unscored courts are `{ team1: null, team2: null }` (initialized by `emptyScores()`), so null-checks compare `sc.team1 === null`, not `sc === null`. Unscored courts are skipped in standings.
- `playersData` — snapshot of `getPlayers()` captured at `generate()` time; used to key the scoreboard so standings iterate a stable 8-player list.
- `courtsData` — two court label strings

**Matchmaking engine** (`buildSchedule()`): runs up to 1500 shuffle attempts per round to minimize partner/opponent repeat penalties. In Balanced mode enforces three fairness constraints (Green-pair rule, ≤2pt strength gap, ≤1pt weakest-player gap) with three fallback tiers if no valid combo is found in 1500 attempts.

**Round ordering (Balanced mode only)**: after all 7 rounds are built, each round's "spread" is computed as the sum of `|skillPts(p1) - skillPts(p2)|` across every team in the round. Rounds are then sorted by descending spread so high-spread pairings (e.g. Green+Red) play early and balanced-partner pairings (e.g. Green+Blue) play late. The court-priority swap (stronger matchup on Court 1) is applied after sorting, keyed on final index. Random mode order is unchanged.

**Skill tiers**: green=4pts (Advanced), blue=3pts (Upper Int.), orange=2pts (Intermediate), red=1pt (Beginner). The Green-Pair Rule is the hardest constraint: G/G teams must only ever face G/G teams.

**Score-entry flow**: pressing "End Round" opens a hidden `.no-print` panel (`#scorePanel`) showing inputs for each court in the current round. Both scores must be non-negative integers and must differ (ties are impossible — sudden-death point is played on court, so the recorded result is never equal). "Save & Continue" validates, stores into `scoresData`, refreshes the score lines in the schedule table, then advances the round. "Skip" advances without storing. "Cancel" closes the panel without advancing. Scroll handling: opening the panel scrolls it into view; on Save & Continue / Skip the advance calls `updateRoundState(false)` to suppress the auto-scroll-to-active-row, then `scrollToTimer()` brings `#timerSection` into view for the next round (avoid double-scrolling if you touch this flow).

**Scoreboard** (`#scoreboard`): `computeStandings()` iterates `roundsData` × `scoresData`, accumulating `{ wins, losses, pf, pa, games }` per player name. Avg Diff = `(PF - PA) / games`, formatted as `+1.50` / `-0.75` / `+0.00`. Sort order: Wins ↓ → Avg Diff ↓ → Points For ↓. Columns: Rank | Player | W | L | PF | PA | +/- Diff.

**Bonus round**: coordinator can append an extra round (1 court or both) via a hidden `.no-print` panel (`#bonusPanel`). Players are manually assigned to teams; the matchup is appended to `roundsData` (length 1 or 2) with a matching `scoresData` entry, `totalRounds` is incremented, and the new round flows through the normal timer + score-entry path. Rounds with index ≥ 7 are labelled "Bonus" in the schedule table.

**Subsystems** (all zero-dependency, browser-native):
- `localStorage` persistence key `pickleball-rr-setup-v1` — saves setup form state
- `localStorage` persistence key `pickleball-rr-session-v1` — saves in-progress tournament state (`roundsData`, `scoresData`, `courtsData`, `currentRound`, `totalRounds`, `playersData`); restored on page reload so a mobile refresh on a court post does not lose recorded scores. `generate()` overwrites the session; `goBack()` preserves it.
- Web Audio API alarm: 1000Hz square wave, 3-beep cycle repeating every 1.5s
- Screen Wake Lock API: held while timer runs, re-acquired on tab visibility restore

## Critical Constraints

**Mobile-first, fluid** — phones are the only target. CSS uses relative units and `clamp()` so type and spacing scale continuously across ~320–430px; there is no device-specific screen breakpoint. The only breakpoint is `@media print`. Any UI change must:
1. Produce no horizontal scroll or clipping anywhere in the 320–430px width range
2. Keep touch targets tappable for outdoors use (~≥36px); prefer adjusting `clamp()` floor/ceiling over adding a breakpoint
3. Preserve Wake Lock (prevents screen sleep during active timer)
4. Preserve audio alarm (loud square-wave synth, must work without user gesture after timer starts)

**All new panels** (`#scorePanel`, `#bonusPanel`) are `.no-print` and must not introduce horizontal scroll across the 320–430px range.

**Print layout** — `window.print()` must render the schedule table on a single letter-size page (scoreboard also prints cleanly via its own `@media print` styles). All `.no-print` elements are hidden in `@media print`.

## Deployment

Push to the `gh-pages` branch — GitHub Pages serves `index.html` directly. The `master` branch holds source/development history.
