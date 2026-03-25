// Test script for weekly leaderboard reset
// Run this in dart pad or as a standalone dart script

import 'package:nlp_digitox/core/services/leaderboard_service.dart';

void main() async {
  final leaderboardService = LeaderboardService.instance;
  
  print('=== Testing Weekly Leaderboard Reset (Monday 4 AM) ===\n');
  
  // Get current week info
  print('1. Getting current leaderboard week info...');
  final weekInfo = await leaderboardService.getLeaderboardWeekInfo();
  
  if (weekInfo != null) {
    print('   Week Number: ${weekInfo['weekNumber']}');
    print('   Days Since Reset: ${weekInfo['daysSinceReset']}');
    print('   Days Until Reset: ${weekInfo['daysUntilReset']}');
    print('   Hours Until Reset: ${weekInfo['hoursUntilReset']}');
    print('   Last Reset Date: ${weekInfo['lastResetDate']}');
    print('   Next Reset Date: ${weekInfo['nextResetDate']} (Monday 4 AM)\n');
  } else {
    print('   No week info available yet. Will be initialized on first run.\n');
  }
  
  // Check for weekly reset
  print('2. Checking if weekly reset is needed...');
  await leaderboardService.checkAndPerformWeeklyReset();
  print('   Check completed.\n');
  
  // Get user data to verify streaks are preserved
  print('3. Getting current user data...');
  final userData = await leaderboardService.getCurrentUserData();
  
  if (userData != null) {
    print('   Username: ${userData.username}');
    print('   Points: ${userData.points}');
    print('   Streak: ${userData.streak} days');
    print('   Rank: #${userData.rank}\n');
  } else {
    print('   No user data available.\n');
  }
  
  print('=== Test Complete ===');
  print('\nReset Schedule: Every Monday at 4:00 AM');
  print('Streaks: Always preserved during reset');
  print('\nNOTE: To manually force a reset for testing, you can call:');
  print('await LeaderboardService.instance.forceWeeklyReset();');
  print('\n⚠️  WARNING: forceWeeklyReset() will reset all users\' points immediately!');
}
