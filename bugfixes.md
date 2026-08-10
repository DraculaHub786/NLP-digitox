diff --git a/android/app/src/main/java/com/nlp/digitox/AppConstants.kt b/android/app/src/main/java/com/nlp/digitox/AppConstants.kt
index d81eb37..4854bcd 100644
--- a/android/app/src/main/java/com/nlp/digitox/AppConstants.kt
+++ b/android/app/src/main/java/com/nlp/digitox/AppConstants.kt
@@ -32,6 +32,8 @@ object AppConstants {
     const val SNAPCHAT_PACKAGE: String = "com.snapchat.android"
     const val FACEBOOK_PACKAGE: String = "com.facebook.katana"
     const val REDDIT_PACKAGE: String = "com.reddit.frontpage"
+    const val X_PACKAGE: String = "com.twitter.android"
+    const val THREADS_PACKAGE: String = "com.instagram.barcelona"
 
     // Static const
     /**
diff --git a/android/app/src/main/java/com/nlp/digitox/enums/PlatformFeatures.kt b/android/app/src/main/java/com/nlp/digitox/enums/PlatformFeatures.kt
index 73a0e91..6650af6 100644
--- a/android/app/src/main/java/com/nlp/digitox/enums/PlatformFeatures.kt
+++ b/android/app/src/main/java/com/nlp/digitox/enums/PlatformFeatures.kt
@@ -10,7 +10,9 @@ enum class PlatformFeatures {
     SNAPCHAT_DISCOVER,
     FACEBOOK_REELS,
     REDDIT_SHORTS,
-    YOUTUBE_SHORTS;
+    YOUTUBE_SHORTS,
+    X_VIDEOS,
+    THREADS_REELS;
 
     companion object {
         fun fromName(name: String): PlatformFeatures? {
@@ -22,6 +24,8 @@ enum class PlatformFeatures {
                 "facebookReels" -> FACEBOOK_REELS
                 "redditShorts" -> REDDIT_SHORTS
                 "youtubeShorts" -> YOUTUBE_SHORTS
+                "xVideos" -> X_VIDEOS
+                "threadsReels" -> THREADS_REELS
                 else -> null
             }
         }
diff --git a/android/app/src/main/java/com/nlp/digitox/services/accessibility/ShortsPlatformManager.kt b/android/app/src/main/java/com/nlp/digitox/services/accessibility/ShortsPlatformManager.kt
index e584182..afa860e 100644
--- a/android/app/src/main/java/com/nlp/digitox/services/accessibility/ShortsPlatformManager.kt
+++ b/android/app/src/main/java/com/nlp/digitox/services/accessibility/ShortsPlatformManager.kt
@@ -7,6 +7,8 @@ import com.nlp.digitox.AppConstants.FACEBOOK_PACKAGE
 import com.nlp.digitox.AppConstants.INSTAGRAM_PACKAGE
 import com.nlp.digitox.AppConstants.REDDIT_PACKAGE
 import com.nlp.digitox.AppConstants.SNAPCHAT_PACKAGE
+import com.nlp.digitox.AppConstants.THREADS_PACKAGE
+import com.nlp.digitox.AppConstants.X_PACKAGE
 import com.nlp.digitox.AppConstants.YOUTUBE_CLIENT_PACKAGE_SUFFIX
 import com.nlp.digitox.AppConstants.YOUTUBE_PACKAGE
 import com.nlp.digitox.enums.PlatformFeatures
@@ -55,6 +57,8 @@ class ShortsPlatformManager(
             FACEBOOK_PACKAGE -> isFacebookFeatureOpen(node, blockedFeatures)
             REDDIT_PACKAGE -> isRedditFeatureOpen(node, blockedFeatures)
             YOUTUBE_PACKAGE -> isYoutubeFeatureOpen(node, blockedFeatures)
+            X_PACKAGE -> isXFeatureOpen(node, blockedFeatures)
+            THREADS_PACKAGE -> isThreadsFeatureOpen(node, blockedFeatures)
             else -> false
         }
 
@@ -155,6 +159,8 @@ class ShortsPlatformManager(
             FACEBOOK_PACKAGE to (90 * 1000L),
             REDDIT_PACKAGE to (60 * 1000L),
             YOUTUBE_PACKAGE to (3 * 60 * 1000L),
+            X_PACKAGE to (90 * 1000L),
+            THREADS_PACKAGE to (60 * 1000L),
         )
 
         // Possible URLs of different short-form content platforms
@@ -263,6 +269,41 @@ class ShortsPlatformManager(
             return PlatformFeatures.REDDIT_SHORTS in blockedFeatures && node.viewIdResourceName == "feed_vertical_pager"
         }
 
+        /**
+         * Checks if X's video/"For you" video surface is open.
+         *
+         * TODO (needs on-device verification): X does not have a single
+         * dedicated "Shorts" surface the way IG/Snap/Reddit/YouTube do — the
+         * closest equivalent is its full-screen vertical video player. The
+         * view ID below is a placeholder and has NOT been confirmed against
+         * a live device — X shipped a full app rewrite (new Kotlin/Compose
+         * codebase) in July 2026, so any older/unverified ID is very likely
+         * wrong. Do not ship this without checking it first — see the
+         * "How to find the real view ID" note in the project TODO doc.
+         */
+        private fun isXFeatureOpen(
+            node: AccessibilityNodeInfo,
+            blockedFeatures: Set<PlatformFeatures>,
+        ): Boolean {
+            return PlatformFeatures.X_VIDEOS in blockedFeatures &&
+                    doesNodeByIdExists(node, "com.twitter.android:id/immersive_video_player") // TODO: verify real ID
+        }
+
+        /**
+         * Checks if Threads' video/Reels-like surface is open.
+         *
+         * TODO (needs on-device verification): same caveat as isXFeatureOpen
+         * — Threads is built on Instagram's codebase, so its internal view
+         * IDs are unconfirmed guesses here, not verified against a live app.
+         */
+        private fun isThreadsFeatureOpen(
+            node: AccessibilityNodeInfo,
+            blockedFeatures: Set<PlatformFeatures>,
+        ): Boolean {
+            return PlatformFeatures.THREADS_REELS in blockedFeatures &&
+                    doesNodeByIdExists(node, "com.instagram.barcelona:id/clips_video_container") // TODO: verify real ID
+        }
+
         /**
          * Checks if the URL contains any of the elements from the provided list of URLs.
          *
diff --git a/lib/core/enums/platform_features.dart b/lib/core/enums/platform_features.dart
index 9df1f66..030520d 100644
--- a/lib/core/enums/platform_features.dart
+++ b/lib/core/enums/platform_features.dart
@@ -9,4 +9,6 @@ enum PlatformFeatures {
   facebookReels,
   redditShorts,
   youtubeShorts,
+  xVideos,
+  threadsReels,
 }
diff --git a/lib/core/services/notification_scheduler_service.dart b/lib/core/services/notification_scheduler_service.dart
index a441590..d73baf9 100644
--- a/lib/core/services/notification_scheduler_service.dart
+++ b/lib/core/services/notification_scheduler_service.dart
@@ -28,6 +28,37 @@ class NotificationSchedulerService {
 
   bool _initialized = false;
 
+  /// Re-checks the Android exact-alarm permission and, if the schedule mode
+  /// would change, re-registers every active schedule under the new mode.
+  ///
+  /// Needed because `initialize()` only computes `_androidScheduleMode` once
+  /// at cold start. If the user hadn't granted "Schedule exact alarms" yet
+  /// at that point, every schedule silently falls back to
+  /// `inexactAllowWhileIdle` for the rest of the app session — even after
+  /// the user grants the permission from Settings — because nothing else
+  /// ever re-evaluates it. That produces notifications that fire late (or
+  /// get deferred by the OS entirely under Doze), which reads as "the
+  /// schedule doesn't trigger when the time arrives."
+  Future<void> refreshScheduleMode(List<NotificationSchedule> schedules) async {
+    if (!_initialized) return;
+
+    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
+        AndroidFlutterLocalNotificationsPlugin>();
+    if (androidPlugin == null) return;
+
+    final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
+    final newMode = (exactAlarmGranted ?? false)
+        ? AndroidScheduleMode.exactAllowWhileIdle
+        : AndroidScheduleMode.inexactAllowWhileIdle;
+
+    if (newMode == _androidScheduleMode) return;
+
+    debugPrint(
+        'Exact alarm permission changed — schedule mode: $_androidScheduleMode -> $newMode. Re-registering schedules.');
+    _androidScheduleMode = newMode;
+    await updateAllSchedules(schedules);
+  }
+
   /// Initialize the notification scheduler service
   Future<void> initialize() async {
     if (_initialized) return;
diff --git a/lib/l10n/app_en.arb b/lib/l10n/app_en.arb
index 2fd9960..0c164e8 100644
--- a/lib/l10n/app_en.arb
+++ b/lib/l10n/app_en.arb
@@ -294,6 +294,10 @@
     "facebook_features_tile_subtitle": "Restrict reels on facebook.",
     "reddit_features_tile_title": "Reddit",
     "reddit_features_tile_subtitle": "Restrict shorts on reddit.",
+    "x_features_tile_title": "X",
+    "x_features_tile_subtitle": "Restrict video feed on X.",
+    "threads_features_tile_title": "Threads",
+    "threads_features_tile_subtitle": "Restrict video/reels on Threads.",
     "@----------------------------- WEBSITES BLOCKING SCREEN-----------------------------": {},
     "websites_blocking_tab_title": "Websites blocking",
     "websites_blocking_tab_info": "Block adult websites and any custom sites you choose to create a safer and more focused online experience. Take charge of your browsing and stay distraction-free.",
diff --git a/lib/providers/notifications/notification_settings_provider.dart b/lib/providers/notifications/notification_settings_provider.dart
index 59080a9..a4fca8e 100644
--- a/lib/providers/notifications/notification_settings_provider.dart
+++ b/lib/providers/notifications/notification_settings_provider.dart
@@ -73,7 +73,13 @@ class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
     final newSchedule = NotificationSchedule(
       label: scheduleName,
       time: time ?? TimeOfDayAdapter.now(),
-      isActive: isActive ?? false,
+      // Default to ON for schedules created through explicit user action
+      // (the "+" FAB). The 4 starter schedules seeded on first install
+      // (Morning/Afternoon/Evening/Night, see defaultNotificationSettingsModel)
+      // intentionally stay OFF until reviewed — but a schedule the user just
+      // took the extra step to name and create is expected to actually be
+      // armed, not silently inactive with no indication in the creation flow.
+      isActive: isActive ?? true,
     );
 
     /// Update state
diff --git a/lib/providers/system/permissions_provider.dart b/lib/providers/system/permissions_provider.dart
index 4886100..122379d 100644
--- a/lib/providers/system/permissions_provider.dart
+++ b/lib/providers/system/permissions_provider.dart
@@ -1,7 +1,9 @@
 import 'package:flutter/widgets.dart';
 import 'package:flutter_animate/flutter_animate.dart';
 import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:nlp_digitox/core/services/drift_db_service.dart';
 import 'package:nlp_digitox/core/services/method_channel_service.dart';
+import 'package:nlp_digitox/core/services/notification_scheduler_service.dart';
 import 'package:nlp_digitox/models/permissions_model.dart';
 
 /// A Riverpod state notifier provider that manages and requests various permissions required by the app.
@@ -259,9 +261,24 @@ class PermissionNotifier extends StateNotifier<PermissionsModel>
   }
 
   /// Requests the Set Exact Alarm permission and updates the internal state.
+  ///
+  /// After the OS permission dialog resolves, also re-checks and, if
+  /// needed, re-registers pending notification schedules — otherwise a
+  /// permission granted mid-session silently has no effect until the app
+  /// is fully restarted (see NotificationSchedulerService.refreshScheduleMode).
   Future<void> askExactAlarmPermission() async {
     await MethodChannelService.instance
         .getAndAskExactAlarmPermission(askPermissionToo: true);
+
+    try {
+      final settings = await DriftDbService
+          .instance.driftDb.uniqueRecordsDao
+          .loadNotificationSettings();
+      await NotificationSchedulerService.instance
+          .refreshScheduleMode(settings.schedules);
+    } catch (e) {
+      debugPrint('Failed to refresh notification schedule mode: $e');
+    }
   }
 
   /// Requests the Ignore Battery Optimization permission and updates the internal state.
diff --git a/lib/ui/common/glass_nav_bar.dart b/lib/ui/common/glass_nav_bar.dart
index 5d44463..323c2c3 100644
--- a/lib/ui/common/glass_nav_bar.dart
+++ b/lib/ui/common/glass_nav_bar.dart
@@ -61,10 +61,12 @@ class GlassNavBar extends StatelessWidget {
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     for (var i = 0; i < items.length; i++)
-                      _PillNavButton(
-                        item: items[i],
-                        selected: i == selectedIndex,
-                        onTap: () => onDestinationSelected(i),
+                      Flexible(
+                        child: _PillNavButton(
+                          item: items[i],
+                          selected: i == selectedIndex,
+                          onTap: () => onDestinationSelected(i),
+                        ),
                       ),
                   ],
                 ),
@@ -98,7 +100,10 @@ class _PillNavButton extends StatelessWidget {
       child: AnimatedContainer(
         duration: const Duration(milliseconds: 220),
         curve: Curves.easeOut,
-        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
+        padding: EdgeInsets.symmetric(
+          horizontal: selected ? 12 : 14,
+          vertical: 10,
+        ),
         decoration: BoxDecoration(
           color: selected ? scheme.primary : Colors.transparent,
           borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
@@ -112,6 +117,11 @@ class _PillNavButton extends StatelessWidget {
                 ]
               : null,
         ),
+        // `mainAxisSize.min` alone isn't enough once this button sits inside
+        // a Flexible — the Row still refuses to size below its children's
+        // intrinsic width, which is what caused the transient overflow band.
+        // Wrapping the label in Flexible+ellipsis lets it shrink/truncate
+        // instead of forcing the whole nav bar wider than the screen.
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
@@ -120,17 +130,26 @@ class _PillNavButton extends StatelessWidget {
               size: 20,
               color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
             ),
-            const SizedBox(width: 6),
             AnimatedSize(
               duration: const Duration(milliseconds: 220),
               curve: Curves.easeOut,
               child: selected
-                  ? Text(
-                      item.label,
-                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
-                            color: scheme.onPrimary,
-                            fontWeight: FontWeight.w600,
-                          ),
+                  ? Padding(
+                      padding: const EdgeInsets.only(left: 6),
+                      child: Flexible(
+                        child: Text(
+                          item.label,
+                          maxLines: 1,
+                          overflow: TextOverflow.ellipsis,
+                          style: Theme.of(context)
+                              .textTheme
+                              .labelMedium
+                              ?.copyWith(
+                                color: scheme.onPrimary,
+                                fontWeight: FontWeight.w600,
+                              ),
+                        ),
+                      ),
                     )
                   : const SizedBox(width: 0),
             ),
diff --git a/lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart b/lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart
index df2200a..81496d9 100644
--- a/lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart
+++ b/lib/ui/screens/shorts_blocking/sliver_shorts_quick_actions.dart
@@ -265,7 +265,7 @@ class SliverShortsQuickActions extends ConsumerWidget {
 
         /// Block reddit shorts
         Padding(
-          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
+          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
           child: Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
@@ -320,6 +320,122 @@ class SliverShortsQuickActions extends ConsumerWidget {
             ),
           ),
         ),
+
+        /// Block X (Twitter) video feed
+        Padding(
+          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
+          child: Container(
+            padding: const EdgeInsets.all(16),
+            decoration: BoxDecoration(
+              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
+              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
+              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
+            ),
+            child: Opacity(
+              opacity: haveNecessaryPerms ? 1 : 0.5,
+              child: Row(
+                children: [
+                  _buildIcon(context, "assets/vectors/x_placeholder.svg"),
+                  const SizedBox(width: 14),
+                  Expanded(
+                    child: Column(
+                      crossAxisAlignment: CrossAxisAlignment.start,
+                      children: [
+                        StyledText(
+                          context.locale.x_features_tile_title,
+                          fontSize: 15,
+                          fontWeight: FontWeight.w600,
+                          maxLines: 1,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                        StyledText(
+                          context.locale.x_features_tile_subtitle,
+                          fontSize: 12,
+                          color: colorScheme.onSurface.withValues(alpha: 0.75),
+                          maxLines: 2,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                      ],
+                    ),
+                  ),
+                  Transform.scale(
+                    scale: 0.85,
+                    child: Switch.adaptive(
+                      value: blockedFeatures.contains(PlatformFeatures.xVideos),
+                      onChanged: haveNecessaryPerms
+                          ? (_) => _toggleFeature(
+                                context,
+                                ref,
+                                blockedFeatures,
+                                PlatformFeatures.xVideos,
+                              )
+                          : null,
+                      activeColor: colorScheme.primary,
+                    ),
+                  ),
+                ],
+              ),
+            ),
+          ),
+        ),
+
+        /// Block Threads video/reels
+        Padding(
+          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
+          child: Container(
+            padding: const EdgeInsets.all(16),
+            decoration: BoxDecoration(
+              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
+              borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
+              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
+            ),
+            child: Opacity(
+              opacity: haveNecessaryPerms ? 1 : 0.5,
+              child: Row(
+                children: [
+                  _buildIcon(context, "assets/vectors/threads_placeholder.svg"),
+                  const SizedBox(width: 14),
+                  Expanded(
+                    child: Column(
+                      crossAxisAlignment: CrossAxisAlignment.start,
+                      children: [
+                        StyledText(
+                          context.locale.threads_features_tile_title,
+                          fontSize: 15,
+                          fontWeight: FontWeight.w600,
+                          maxLines: 1,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                        StyledText(
+                          context.locale.threads_features_tile_subtitle,
+                          fontSize: 12,
+                          color: colorScheme.onSurface.withValues(alpha: 0.75),
+                          maxLines: 2,
+                          overflow: TextOverflow.ellipsis,
+                        ),
+                      ],
+                    ),
+                  ),
+                  Transform.scale(
+                    scale: 0.85,
+                    child: Switch.adaptive(
+                      value: blockedFeatures.contains(PlatformFeatures.threadsReels),
+                      onChanged: haveNecessaryPerms
+                          ? (_) => _toggleFeature(
+                                context,
+                                ref,
+                                blockedFeatures,
+                                PlatformFeatures.threadsReels,
+                              )
+                          : null,
+                      activeColor: colorScheme.primary,
+                    ),
+                  ),
+                ],
+              ),
+            ),
+          ),
+        ),
       ],
     );
   }
diff --git a/lib/ui/splash_screen.dart b/lib/ui/splash_screen.dart
index 6662691..baa0167 100644
--- a/lib/ui/splash_screen.dart
+++ b/lib/ui/splash_screen.dart
@@ -167,9 +167,13 @@ class _SplashScreenState extends ConsumerState<SplashScreen> {
                     ),
                   ),
                   padding: const EdgeInsets.all(32),
-                  child: ClipOval(
+                  // Splash uses the square "prev" artwork (not the round
+                  // in-app logo/notification icon) so the full mark reads
+                  // clearly before it's ever cropped into a circle.
+                  child: ClipRRect(
+                    borderRadius: BorderRadius.circular(24),
                     child: Image.asset(
-                      'assets/logo.png',
+                      'assets/logo-prev.png',
                       width: 80,
                       height: 80,
                       fit: BoxFit.cover,
diff --git a/pubspec.yaml b/pubspec.yaml
index 7673af0..0ebffd0 100644
--- a/pubspec.yaml
+++ b/pubspec.yaml
@@ -95,6 +95,7 @@ flutter:
   assets:
     # App Logo
     - assets/logo.png
+    - assets/logo-prev.png
     
     # Onboarding
     - assets/illustrations/onboarding_1.png
@@ -114,6 +115,8 @@ flutter:
     - assets/vectors/youtube.svg
     - assets/vectors/facebook.svg
     - assets/vectors/reddit.svg
+    - assets/vectors/x_placeholder.svg
+    - assets/vectors/threads_placeholder.svg
 
   fonts:
     - family: Alice