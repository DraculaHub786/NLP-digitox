// Dialog for verifying parental control password

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/core/services/parental_password_service.dart';

/// Shows a dialog to verify the parental control password
/// Returns true if password is verified, false otherwise
Future<bool> showParentalPasswordVerifyDialog({
  required BuildContext context,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _ParentalPasswordVerifyDialog(),
  );
  
  return result ?? false;
}

class _ParentalPasswordVerifyDialog extends StatefulWidget {
  const _ParentalPasswordVerifyDialog();

  @override
  State<_ParentalPasswordVerifyDialog> createState() =>
      _ParentalPasswordVerifyDialogState();
}

class _ParentalPasswordVerifyDialogState
    extends State<_ParentalPasswordVerifyDialog>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isVerifying = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Please enter password";
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final isCorrect =
        await ParentalPasswordService.instance.verifyPassword(password);

    if (!mounted) return;

    if (isCorrect) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = "Incorrect password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          title: Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  FluentIcons.shield_lock_20_filled,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  "Parental Access",
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter password to access parental controls.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofocus: true,
                  enabled: !_isVerifying,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(FluentIcons.lock_closed_20_regular),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? FluentIcons.eye_20_regular
                            : FluentIcons.eye_off_20_regular,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _verifyPassword(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isVerifying ? null : () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: _isVerifying ? null : _verifyPassword,
              child: _isVerifying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
