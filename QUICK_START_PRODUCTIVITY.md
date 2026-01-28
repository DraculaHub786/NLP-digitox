# Quick Start Guide: Productivity & Points System

## 🎯 For Users

### How Daily Resets Work
- **When**: Automatically at midnight every day
- **What gets reset**:
  - ✅ Habit completion checkboxes
  - ✅ Task completion status
  - ⚡ Streaks only break if you missed yesterday

### How Streaks Work
- Complete a habit today → Streak +1
- Skip a day → Streak resets to 0
- Your streak shows real consecutive days! 🔥

### How to Earn Points

#### Productivity Activities
- ✅ **Complete a habit**: +30 points
- ✅ **Complete a task**: +20 points  
- ✅ **Maintain daily streak**: +15 points/day

#### Other Activities (Auto-tracked)
- 📱 **Stay within screen time goal**: +50 points/day
- 😴 **Follow bedtime schedule**: +25 points/night
- 🚫 **Respect app restrictions**: +10 points/day

**Total possible per day**: 100+ points!

### Notifications You'll Get
1. **8 PM Daily Reminder**: If you have incomplete habits/tasks
2. **Streak Milestones**: At 7, 30, 50+ day streaks
3. **Points Earned**: When you complete activities (optional)

## 🛠️ For Developers

### Quick Integration Examples

#### 1. Award Points Manually
```dart
// For screen time goal
await ProductivityPointsService.instance.awardScreenTimeGoalPoints();

// For bedtime adherence  
await ProductivityPointsService.instance.awardBedtimeSchedulePoints();

// For app restrictions
await ProductivityPointsService.instance.awardAppRestrictionPoints();
```

#### 2. Force a Reset (Testing)
```dart
await ProductivityResetService.instance.forceReset();
```

#### 3. Check Last Reset
```dart
final lastReset = await ProductivityResetService.instance.getLastResetDate();
print('Last reset: $lastReset');
```

#### 4. Send Custom Notification
```dart
await ProductivityNotificationService.instance.sendIncompleteItemsNotification(
  incompleteHabitsCount: 2,
  incompleteTasksCount: 3,
);
```

### Service Initialization
Already done in `initializer.dart`:
```dart
await ProductivityNotificationService.instance.initialize();
await ProductivityResetService.instance.initialize();
```

### Points Service Methods
```dart
// Habit completion (auto-called in provider)
await _pointsService.awardHabitCompletionPoints(habitName: 'Exercise');

// Task completion (auto-called in provider)
await _pointsService.awardTaskCompletionPoints(taskTitle: 'Study');

// Daily streak (auto-called in provider)
await _pointsService.awardDailyStreakPoints(streak: 15);

// Screen time goal (call from your screen time tracker)
await _pointsService.awardScreenTimeGoalPoints();

// Bedtime schedule (call from bedtime tracker)
await _pointsService.awardBedtimeSchedulePoints();

// App restrictions (call from restriction manager)
await _pointsService.awardAppRestrictionPoints();
```

## 🔍 Debugging

### Check if Reset is Working
```dart
// In your debug console
final service = ProductivityResetService.instance;
final lastReset = await service.getLastResetDate();
debugPrint('Last reset: $lastReset');
```

### Check Points History
```dart
final user = await LeaderboardService.instance.getCurrentUserData();
debugPrint('Points: ${user?.points}');
debugPrint('Breakdown: ${user?.pointsBreakdown}');
```

### Test Notifications
```dart
// Send test notification
await ProductivityNotificationService.instance.sendIncompleteItemsNotification(
  incompleteHabitsCount: 1,
  incompleteTasksCount: 1,
);
```

## 📱 Testing Checklist

### Daily Reset Testing
- [ ] Complete a habit
- [ ] Wait 24 hours (or change device time)
- [ ] Verify habit shows unchecked
- [ ] Verify streak maintained if completed yesterday
- [ ] Verify streak reset if skipped yesterday

### Points Testing
- [ ] Complete a habit → Check for +30 points
- [ ] Complete a task → Check for +20 points
- [ ] Check leaderboard updates in real-time
- [ ] Verify points breakdown in Firestore
- [ ] Try completing same item twice (should only count once per day for some)

### Notification Testing
- [ ] Set time to 8 PM
- [ ] Leave items incomplete
- [ ] Check for reminder notification
- [ ] Complete 7-day streak → Check for milestone notification
- [ ] Complete activity → Check for points notification

## 🎨 UI Updates Needed (Optional)

You may want to add these UI enhancements:

### 1. Points Badge in Dashboard
```dart
// Show today's points earned
Text('Points today: ${todayPoints}')
```

### 2. Streak Indicator
```dart
// Show current streak with fire emoji
Row(
  children: [
    Icon(Icons.local_fire_department, color: Colors.orange),
    Text('${streak} days'),
  ],
)
```

### 3. Progress Bar
```dart
// Show progress to next reward
LinearProgressIndicator(
  value: currentPoints / nextMilestone,
)
```

## ⚠️ Important Notes

1. **Notification Permissions**: Ask user for permission on first app launch
2. **Background Execution**: Reset checks run hourly when app is active
3. **Firestore Rules**: Ensure users can write to their leaderboard document
4. **Testing**: Use device time changes carefully (can affect other features)

## 🚀 Next Steps

1. Test the daily reset overnight
2. Complete some habits and verify points
3. Check the leaderboard for updates
4. Monitor notifications at 8 PM
5. Celebrate your first 7-day streak! 🎉

---

Need help? Check [PRODUCTIVITY_IMPLEMENTATION.md](./PRODUCTIVITY_IMPLEMENTATION.md) for detailed documentation.
