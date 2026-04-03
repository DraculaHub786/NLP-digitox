import 'package:flutter/material.dart';
import 'dart:async';

/// iOS Soft-Lock Overlay Widget
/// 
/// Since iOS doesn't allow true app blocking without MDM,
/// this provides a "soft lock" overlay that appears when restrictions are active.
/// Users can dismiss it, but it creates friction and awareness.
class SoftLockOverlay extends StatefulWidget {
  final String appName;
  final String packageName;
  final String reason;
  final VoidCallback onDismiss;
  final Duration? remainingTime;
  final bool allowEmergencyUnlock;

  const SoftLockOverlay({
    super.key,
    required this.appName,
    required this.packageName,
    required this.reason,
    required this.onDismiss,
    this.remainingTime,
    this.allowEmergencyUnlock = true,
  });

  @override
  State<SoftLockOverlay> createState() => _SoftLockOverlayState();
}

class _SoftLockOverlayState extends State<SoftLockOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  int _emergencyTapCount = 0;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Auto-dismiss after 5 seconds as a soft lock
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _handleEmergencyTap() {
    if (!widget.allowEmergencyUnlock) return;

    _emergencyTapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(seconds: 2), () {
      _emergencyTapCount = 0;
    });

    if (_emergencyTapCount >= 7) {
      // Emergency unlock after 7 taps
      _showEmergencyUnlockDialog();
    }
  }

  void _showEmergencyUnlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Emergency Unlock'),
        content: const Text(
          'You\'re about to override this restriction. This action will be logged. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _dismiss(isEmergency: true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Override'),
          ),
        ],
      ),
    );
  }

  void _dismiss({bool isEmergency = false}) {
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withOpacity(0.95),
        child: SafeArea(
          child: GestureDetector(
            onTap: _handleEmergencyTap,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reason,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.remainingTime != null) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Available in ${_formatDuration(widget.remainingTime!)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  const Text(
                    '💡 Take this moment to:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getSuggestions().map((suggestion) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• $suggestion',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _dismiss(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'I Understand',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.allowEmergencyUnlock)
                    Text(
                      'Tap 7 times for emergency access',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  List<String> _getSuggestions() {
    return [
      'Reflect on your goals',
      'Take a mindful breath',
      'Do a quick stretch',
      'Check your to-do list',
    ];
  }
}

/// Service to manage soft-lock overlays
class SoftLockService extends ChangeNotifier {
  static final SoftLockService _instance = SoftLockService._internal();
  factory SoftLockService() => _instance;
  SoftLockService._internal();

  bool _isOverlayVisible = false;
  String? _currentBlockedApp;

  bool get isOverlayVisible => _isOverlayVisible;
  String? get currentBlockedApp => _currentBlockedApp;

  void showSoftLock(String packageName, String appName, String reason) {
    _isOverlayVisible = true;
    _currentBlockedApp = packageName;
    notifyListeners();
  }

  void dismissSoftLock() {
    _isOverlayVisible = false;
    _currentBlockedApp = null;
    notifyListeners();
  }
}
