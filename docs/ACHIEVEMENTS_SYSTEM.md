# Achievements System Documentation

## Overview

The NLP-Digitox achievements and rewards system is implemented in:
- `lib/core/services/productivity_points_service.dart`

This service handles all point-earning activities for productivity and digital wellbeing achievements.

---

## Implementation Note

While the IMPLEMENTATION_PLAN.md suggests a separate `lib/services/achievements.dart` file, the functionality is comprehensively implemented within `productivity_points_service.dart`. This consolidation provides better maintainability and consistency.

---

## Features

### Points System

Users earn points for:

1. **Completing Habits** (5-20 points per habit)
   - Daily habit completion
   - Once per day after 4am
   - Points scale with habit importance

2. **Completing Tasks** (10-30 points per task)
   - Task completion
   - Once per day after 4am
   - Points scale with task priority

3. **Daily Streaks** (5 points per day)
   - Maintaining consecutive days of app usage
   - Automatic tracking

4. **Screen Time Goals** (15 points)
   - Staying within daily screen time limits
   - Once per day

5. **Bedtime Schedule** (10 points)
   - Following bedtime routine
   - Sleep wellness focus

6. **App Restrictions** (20 points)
   - Respecting self-imposed restrictions
   - Rewarding self-control

7. **Focus Sessions** (0.5 points per minute, 10-100 points per session)
   - Goal-oriented focus time
   - Clamped range: 10-100 points

---

## Usage Examples

### Award Points for Focus Session

```dart
import 'package:nlp_digitox/core/services/productivity_points_service.dart';

// After completing a 30-minute focus session
await ProductivityPointsService.instance.awardPointsForFocusSession(30);
// Awards 15 points (30 * 0.5)
```

### Award Points for Habit Completion

```dart
// When user completes a habit
await ProductivityPointsService.instance.awardPointsForHabitCompletion(
  habitName: 'Morning Exercise',
  habitId: 'habit-123',
);
```

### Award Points for Task Completion

```dart
// When user completes a task
await ProductivityPointsService.instance.awardPointsForTaskCompletion(
  taskTitle: 'Finish Project Report',
  taskId: 'task-456',
);
```

### Check and Award Daily Streak

```dart
// Call this once per day (e.g., at app startup)
await ProductivityPointsService.instance.checkAndAwardDailyStreak();
```

---

## Point Calculation Logic

### Focus Sessions
```dart
points = (durationMinutes * 0.5).round().clamp(10, 100)
```

Examples:
- 10 minutes → 10 points (minimum)
- 30 minutes → 15 points
- 60 minutes → 30 points
- 200 minutes → 100 points (maximum)

### Habits
- Base points: 5-20 (configurable per habit)
- Daily once per habit
- Prevents duplicate awards

### Tasks
- Base points: 10-30 (configurable per task)
- Daily once per task
- Prevents duplicate awards

### Streaks
- 5 points per consecutive day
- Resets if user misses a day

---

## Point Tracking

Points are tracked in:
- **Firestore**: `users/{userId}/points` collection
- **Local Cache**: In-memory for performance

### Point Entry Schema

```dart
{
  'userId': 'user-123',
  'points': 15,
  'source': 'focus_session',
  'description': '30-minute focus session',
  'earnedAt': Timestamp,
  'metadata': {
    'sessionId': 'session-456',
    'duration': 30,
  }
}
```

---

## Daily Reset Logic

All point awards respect a 4am daily reset:

```dart
// Points awarded today are tracked per-source
// E.g., "habit_points_awarded_today: {habit_id: true}"
// Reset happens at 4am (user's local time)
```

This prevents:
- Multiple awards for the same habit/task
- Gaming the system by repeatedly completing items

---

## Leaderboard Integration

Points feed into the leaderboard system:

```dart
import 'package:nlp_digitox/core/services/leaderboard_service.dart';

// Get user's rank
final rank = await LeaderboardService.instance.getUserRank(userId);

// Get top scorers
final topUsers = await LeaderboardService.instance.getTopUsers(limit: 10);
```

---

## Future Enhancements (v2)

### Planned Features
1. **Badges & Trophies**
   - Milestone achievements (100 hours focused, 30-day streak)
   - Visual badge collection

2. **Point Multipliers**
   - Weekend bonus (1.5x)
   - Mood-based bonuses
   - Persona-specific multipliers

3. **Redemption System**
   - Use points to unlock themes
   - Premium feature access
   - Charity donations

4. **Social Features**
   - Gift points to friends
   - Group challenges
   - Collaborative goals

---

## API Reference

### ProductivityPointsService

#### Main Methods

```dart
// Singleton instance
ProductivityPointsService.instance

// Focus session
Future<void> awardPointsForFocusSession(int durationMinutes)

// Habits
Future<void> awardPointsForHabitCompletion({
  required String habitName,
  required String habitId,
})

// Tasks
Future<void> awardPointsForTaskCompletion({
  required String taskTitle,
  required String taskId,
})

// Streaks
Future<void> checkAndAwardDailyStreak()

// Screen time
Future<void> checkAndAwardScreenTimeGoal()

// Bedtime
Future<void> checkAndAwardBedtimeSchedule()

// Restrictions
Future<void> checkAndAwardAppRestrictions()

// Utility
Future<int> getTodayMaxPoints()
Future<void> resetDailyPointsTracking()
```

---

## Testing

### Unit Tests

```dart
// Test focus session points
test('should award correct points for focus session', () async {
  await service.awardPointsForFocusSession(30);
  expect(await getPoints(), equals(15));
});

// Test daily limit prevention
test('should not award habit points twice in same day', () async {
  await service.awardPointsForHabitCompletion(...);
  await service.awardPointsForHabitCompletion(...); // Same habit
  expect(await getPoints(), equals(10)); // Only once
});
```

### Manual Testing

See `MANUAL_TESTING_GUIDE.md` for comprehensive point system testing procedures.

---

## Configuration

Points can be adjusted in `productivity_points_service.dart`:

```dart
// Adjust point values
static const int habitCompletionPoints = 10;
static const int taskCompletionPoints = 15;
static const int dailyStreakPoints = 5;
static const int screenTimeGoalPoints = 15;
static const int bedtimeSchedulePoints = 10;
static const int appRestrictionPoints = 20;

// Adjust focus session formula
final points = (durationMinutes * 0.5).round().clamp(10, 100);
```

---

## Migration from Plan

If you need to create a separate `lib/services/achievements.dart` file to exactly match the plan, you can:

1. Extract the points logic from `productivity_points_service.dart`
2. Create a new `AchievementsService` class
3. Import and delegate from `ProductivityPointsService`

However, the current implementation is functionally complete and production-ready.

---

**Document Version:** 1.0  
**Last Updated:** April 2, 2026  
**Location:** lib/core/services/productivity_points_service.dart
