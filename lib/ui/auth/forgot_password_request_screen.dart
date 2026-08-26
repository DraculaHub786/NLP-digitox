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

class ForgotPasswordRequestScreen extends StatefulWidget {
  const ForgotPasswordRequestScreen({super.key});

  @override
  State<ForgotPasswordRequestScreen> createState() =>
      _ForgotPasswordRequestScreenState();
}

class _ForgotPasswordRequestScreenState
    extends State<ForgotPasswordRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  static const String _n8nBaseUrl = 'https://n8n.nlpdigitox.me';

  @override
  void dispose() {
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _cooldownSeconds = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
      });
      if (_cooldownSeconds <= 0) {
        timer.cancel();
        setState(() => _isCooldown = false);
      }
    });
  }

  Future<void> _sendOtpRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_n8nBaseUrl/webhook/request-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': _emailController.text.trim()}),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _startCooldown();
        context.showSnackAlert(
          'OTP sent to your email',
          icon: FluentIcons.mail_checkmark_20_filled,
        );
        Navigator.of(context).pushNamed(
          AppRoutes.forgotPasswordOtpPath,
          arguments: {'email': _emailController.text.trim()},
        );
      } else {
        context.showSnackAlert(
          data['error'] ?? 'Failed to send OTP. Please try again.',
          icon: FluentIcons.error_circle_20_filled,
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      context.showSnackAlert(
        'Request timed out. Please try again.',
        icon: FluentIcons.error_circle_20_filled,
      );
    } catch (e) {
      if (!mounted) return;
      context.showSnackAlert(
        'Connection error. Please check your connection and try again.',
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
        title: const Text('Forgot Password'),
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
                        FluentIcons.key_20_regular,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 20.0),

                    /// Title
                    StyledText(
                      'Reset Your Password',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      color: colorScheme.onSurface,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 8.0),

                    StyledText(
                      'Enter your email and we\'ll send you a 6-digit code to reset your password.',
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      textAlign: TextAlign.center,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 32.0),

                    /// Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _modernFieldDecoration(
                        context,
                        label: 'Email',
                        hint: 'Enter your email',
                        prefixIcon: FluentIcons.mail_20_regular,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 28.0),

                    /// Send Code button
                    PillButton(
                      label: _isLoading
                          ? null
                          : _isCooldown
                              ? 'Resend in $_cooldownSeconds s'
                              : 'Send Code',
                      onPressed:
                          (_isLoading || _isCooldown) ? null : _sendOtpRequest,
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
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.loginPath,
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
