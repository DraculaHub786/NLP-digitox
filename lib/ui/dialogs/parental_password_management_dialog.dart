// Dialog for managing (changing/resetting) parental control password

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/core/services/parental_password_service.dart';

/// Shows a dialog to manage the parental control password (change or reset)
Future<void> showParentalPasswordManagementDialog({
  required BuildContext context,
}) async {
  await showDialog(
    context: context,
    builder: (context) => const _ParentalPasswordManagementDialog(),
  );
}

class _ParentalPasswordManagementDialog extends StatefulWidget {
  const _ParentalPasswordManagementDialog();

  @override
  State<_ParentalPasswordManagementDialog> createState() =>
      _ParentalPasswordManagementDialogState();
}

class _ParentalPasswordManagementDialogState
    extends State<_ParentalPasswordManagementDialog>
    with SingleTickerProviderStateMixin {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (oldPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please enter current password";
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please enter new password";
      });
      return;
    }

    if (newPassword.length < 4) {
      setState(() {
        _errorMessage = "New password must be at least 4 characters";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = "New passwords do not match";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Verify old password
    final isOldPasswordCorrect =
        await ParentalPasswordService.instance.verifyPassword(oldPassword);

    if (!mounted) return;

    if (!isOldPasswordCorrect) {
      setState(() {
        _isProcessing = false;
        _errorMessage = "Current password is incorrect";
      });
      return;
    }

    // Set new password
    final success =
        await ParentalPasswordService.instance.setPassword(newPassword);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      setState(() {
        _successMessage = "Password changed successfully!";
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      // Close dialog after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } else {
      setState(() {
        _errorMessage = "Failed to change password. Please try again.";
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
              Icon(
                FluentIcons.shield_lock_20_filled,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  "Change Password",
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
              "Change your parental control password.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(FluentIcons.lock_closed_20_regular),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? FluentIcons.eye_20_regular
                        : FluentIcons.eye_off_20_regular,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: "New Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(FluentIcons.lock_closed_20_regular),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? FluentIcons.eye_20_regular
                        : FluentIcons.eye_off_20_regular,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(FluentIcons.lock_closed_20_regular),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? FluentIcons.eye_20_regular
                        : FluentIcons.eye_off_20_regular,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _changePassword(),
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
            if (_successMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _successMessage!,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isProcessing ? null : _changePassword,
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Change"),
        ),
      ],
        ),
      ),
    );
  }
}
