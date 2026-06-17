# Leaderboard Fixes Summary

## Problems Fixed

### 1. Weekly Reset Not Happening
- `checkAndPerformWeeklyReset()` was defined but had a batch limit issue — Firestore batches max out at 500 operations
- **Fix**: Chunked the reset into batches of 500, looped until all users processed

### 2. Leaderboard Points Were Lifetime Points
- Leaderboard was showing `points` (Firestore field) but until the weekly reset ran, `points` and `lifetimePoints` were incremented identically
- **Fix**: `addPoints()` correctly increments both separately. Weekly reset zeroes `points` + `pointsBreakdown` but preserves `lifetimePoints`. Achievements screen now shows `lifetimePoints`.

### 3. Streak Was False / Never Calculated
- `evaluateAndUpdateStreak()` was defined in `LeaderboardService` but **never called** anywhere
- `productivity_points_service.dart` was overwriting `streak` via `updateStreak()` with a counter unrelated to screen time
- **Fix**:
  - `evaluateAndUpdateStreak()` is now called in `initializer.dart` on app start + a 6-hour periodic timer
  - All `updateStreak()` calls removed from `productivity_points_service.dart` — streak is exclusively managed by screen-time-based evaluation
  - Streak rule: screen time < 8hrs → +1, ≥ 8hrs → reset to 0

### 4. Achievements Screen Used Wrong Points Field
- Was showing `pointsBreakdown.values` which resets weekly
- **Fix**: Shows `lifetimePoints` as the primary total, weekly breakdown shown as secondary "This Week's Breakdown"

## Files Modified

| File | Changes |
|------|---------|
| `lib/core/services/leaderboard_service.dart` | Chunked batch reset (500/batch), added `startDailyStreakEvaluation()`, preserved existing data in `updateUserData()` |
| `lib/initializer.dart` | Added `evaluateAndUpdateStreak()` + `startDailyStreakEvaluation()` calls |
| `lib/ui/screens/achievements/achievements_screen.dart` | Shows `lifetimePoints` instead of weekly breakdown total |
| `lib/core/services/productivity_points_service.dart` | Removed all `updateStreak()` calls that conflicted with the new streak system |

## How It Works Now

| Feature | Behavior |
|---------|----------|
| **Weekly leaderboard reset** | Every Monday at 4 AM → `points` & `pointsBreakdown` → 0, `lifetimePoints` preserved |
| **Points shown on leaderboard** | Weekly `points` (reset every Monday) |
| **Streak** | Screen time < 8hrs/day → streak +1, ≥ 8hrs/day → streak 0. Evaluated every 6 hours |
| **Achievements → Points** | Shows `lifetimePoints` (all-time total, never reset) |
| **Achievements → Breakdown** | Shows current week's `pointsBreakdown` categories |

## Verification
- `dart analyze lib/` — no new errors (only pre-existing deprecation warnings)
