// Wrapper for parental controls screen with password authentication

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/parental_password_service.dart';
import 'package:nlp_digitox/ui/dialogs/parental_password_setup_dialog.dart';
import 'package:nlp_digitox/ui/dialogs/parental_password_verify_dialog.dart';
import 'package:nlp_digitox/ui/screens/parental_controls/parental_controls_screen.dart';

/// Wrapper widget that handles password authentication before showing parental controls
class ParentalControlsGate extends StatefulWidget {
  const ParentalControlsGate({super.key});

  @override
  State<ParentalControlsGate> createState() => _ParentalControlsGateState();
}

class _ParentalControlsGateState extends State<ParentalControlsGate> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Check if password is set
    final isPasswordSet =
        await ParentalPasswordService.instance.isPasswordSet();

    if (!mounted) return;

    if (!isPasswordSet) {
      // No password set, prompt to create one
      final password = await showParentalPasswordSetupDialog(context: context);

      if (!mounted) return;

      if (password == null) {
        // User cancelled setup, go back
        Navigator.of(context).pop();
        return;
      }

      // Save the password
      final success =
          await ParentalPasswordService.instance.setPassword(password);

      if (!mounted) return;

      if (success) {
        context.showSnackAlert(
          "Parental control password set successfully",
          icon: FluentIcons.shield_checkmark_20_filled,
        );
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      } else {
        context.showSnackAlert(
          "Failed to set password. Please try again.",
          icon: FluentIcons.error_circle_20_filled,
        );
        Navigator.of(context).pop();
      }
    } else {
      // Password is set, verify it
      final isVerified =
          await showParentalPasswordVerifyDialog(context: context);

      if (!mounted) return;

      if (isVerified) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      } else {
        // Authentication failed, go back
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const ParentalControlsScreen();
    }

    // This should not be reached, but just in case
    return const Scaffold(
      body: Center(
        child: Text("Authentication required"),
      ),
    );
  }
}
