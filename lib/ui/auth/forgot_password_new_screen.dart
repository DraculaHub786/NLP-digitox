import 'dart:async';
import 'dart:convert';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';

class ForgotPasswordNewScreen extends StatefulWidget {
  const ForgotPasswordNewScreen({super.key});

  @override
  State<ForgotPasswordNewScreen> createState() =>
      _ForgotPasswordNewScreenState();
}

class _ForgotPasswordNewScreenState extends State<ForgotPasswordNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  double _passwordStrength = 0.0;
  List<String> _passwordIssues = [];

  /// Update this when you deploy n8n to a public HTTPS server.
  static const String _n8nBaseUrl = 'http://localhost:5678';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _email {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['email'] as String? ?? '';
  }

  String get _resetToken {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['resetToken'] as String? ?? '';
  }

  /// Reused password strength logic — identical to signup screen (Part K).
  void _evaluatePasswordStrength(String password) {
    final issues = <String>[];
    double score = 0;

    if (password.length >= 8) {
      score += 0.25;
    } else {
      issues.add('At least 8 characters');
    }
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 0.25;
    } else {
      issues.add('One uppercase letter');
    }
    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 0.25;
    } else {
      issues.add('One number');
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score += 0.25;
    } else {
      issues.add('One special character');
    }

    setState(() {
      _passwordStrength = score;
      _passwordIssues = issues;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordIssues.isNotEmpty) {
      context.showSnackAlert(
        'Please meet all password requirements',
        icon: FluentIcons.shield_error_20_filled,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_n8nBaseUrl/webhook-test/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': _email,
              'resetToken': _resetToken,
              'newPassword': _newPasswordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        context.showSnackAlert(
          'Password reset successful! Please log in with your new password.',
          icon: FluentIcons.checkmark_circle_20_filled,
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginPath,
          (route) => false,
        );
      } else {
        context.showSnackAlert(
          data['error'] ?? 'Failed to reset password. Please try again.',
          icon: FluentIcons.error_circle_20_filled,
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      context.showSnackAlert(
        'Request timed out. Make sure n8n is running.',
        icon: FluentIcons.error_circle_20_filled,
      );
    } catch (e) {
      if (!mounted) return;
      context.showSnackAlert(
        'Connection error. Is n8n running on localhost:5678?',
        icon: FluentIcons.error_circle_20_filled,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _modernFieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor =
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    OutlineInputBorder border(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        prefixIcon,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      border: border(borderColor, 1),
      enabledBorder: border(borderColor, 1),
      focusedBorder: border(colorScheme.primary, 1.5),
      errorBorder: border(colorScheme.error, 1),
      focusedErrorBorder: border(colorScheme.error, 1.5),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: TreatedBackgroundImage(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Icon — glass-chip style
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        border: Border.all(
                          color: (Theme.of(context).brightness == Brightness.dark ? DesignPalette.darkGlassBorder : DesignPalette.lightGlassBorder),
                        ),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Icon(
                        FluentIcons.key_reset_20_regular,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 20.0),

                    /// Title
                    StyledText(
                      'Set New Password',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      color: colorScheme.onSurface,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 8.0),

                    StyledText(
                      'Choose a strong new password for $_email',
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      textAlign: TextAlign.center,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 32.0),

                    /// New password field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      onChanged: _evaluatePasswordStrength,
                      decoration: _modernFieldDecoration(
                        context,
                        label: 'New Password',
                        hint: 'Enter new password',
                        prefixIcon: FluentIcons.lock_closed_20_regular,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? FluentIcons.eye_20_regular
                                : FluentIcons.eye_off_20_regular,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() => _obscureNew = !_obscureNew);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate(effects: DefaultEffects.transitionIn),

                    /// Password strength indicator (same as signup)
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: _passwordStrength < 0.5
                            ? const Color(0xFFB5453A)
                            : _passwordStrength < 1.0
                                ? const Color(0xFFC9922E)
                                : const Color(0xFF838764),
                      ),
                    ),
                    if (_passwordIssues.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ..._passwordIssues.map(
                        (issue) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.dismiss_circle_12_regular,
                                size: 12,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              StyledText(
                                issue,
                                fontSize: 12,
                                color: colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16.0),

                    /// Confirm new password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: _modernFieldDecoration(
                        context,
                        label: 'Confirm New Password',
                        hint: 'Re-enter new password',
                        prefixIcon: FluentIcons.lock_closed_20_regular,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? FluentIcons.eye_20_regular
                                : FluentIcons.eye_off_20_regular,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() =>
                                _obscureConfirm = !_obscureConfirm);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 28.0),

                    /// Reset Password button
                    PillButton(
                      label: _isLoading ? null : 'Reset Password',
                      onPressed: _isLoading ? null : _resetPassword,
                      fullWidth: true,
                      child: _isLoading
                          ? SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : null,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 24.0),

                    /// Back to login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StyledText(
                          'Remember your password? ',
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.loginPath,
                              (route) => false,
                            );
                          },
                          child: StyledText(
                            'Login',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ).animate(effects: DefaultEffects.transitionIn),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
