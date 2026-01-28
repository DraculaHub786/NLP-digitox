// Dialog for setting up parental control password

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Shows a dialog to set up a new parental control password
Future<String?> showParentalPasswordSetupDialog({
  required BuildContext context,
}) async {
  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _ParentalPasswordSetupDialog(),
  );
}

class _ParentalPasswordSetupDialog extends StatefulWidget {
  const _ParentalPasswordSetupDialog();

  @override
  State<_ParentalPasswordSetupDialog> createState() =>
      _ParentalPasswordSetupDialogState();
}

class _ParentalPasswordSetupDialogState
    extends State<_ParentalPasswordSetupDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _errorMessage = null;
    });

    if (password.isEmpty) {
      setState(() {
        _errorMessage = "Password cannot be empty";
      });
      return;
    }

    if (password.length < 4) {
      setState(() {
        _errorMessage = "Password must be at least 4 characters";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            FluentIcons.shield_lock_20_filled,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text("Set Parental Password"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a password to protect parental controls. This is separate from your device password.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
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
              onSubmitted: (_) => _validateAndSubmit(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
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
              onSubmitted: (_) => _validateAndSubmit(),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _validateAndSubmit,
          child: const Text("Set Password"),
        ),
      ],
    );
  }
}
