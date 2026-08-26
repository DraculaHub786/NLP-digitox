import 'dart:async';
import 'dart:convert';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  static const String _n8nBaseUrl = 'https://n8n.nlpdigitox.me';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _email {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['email'] as String? ?? '';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      context.showSnackAlert(
        'Please enter the full 6-digit code',
        icon: FluentIcons.error_circle_20_filled,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_n8nBaseUrl/webhook/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': _email, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final resetToken = data['resetToken'] as String? ?? '';
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.forgotPasswordNewPath,
          arguments: {
            'email': _email,
            'resetToken': resetToken,
          },
        );
      } else {
        context.showSnackAlert(
          data['error'] ?? 'Invalid or expired code. Please try again.',
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Code'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: TreatedBackgroundImage(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      FluentIcons.shield_lock_20_regular,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 20.0),

                  /// Title
                  StyledText(
                    'Verification Code',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    color: colorScheme.onSurface,
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 8.0),

                  StyledText(
                    'We sent a 6-digit code to $_email. Enter it below to verify your identity.',
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    textAlign: TextAlign.center,
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 32.0),

                  /// OTP input field
                  TextFormField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 12,
                      color: colorScheme.onSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.xl),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        _verifyOtp();
                      }
                    },
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 28.0),

                  /// Verify button
                  PillButton(
                    label: _isLoading ? null : 'Verify Code',
                    onPressed: _isLoading ? null : _verifyOtp,
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

                  /// Resend link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StyledText(
                        "Didn't receive the code? ",
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: StyledText(
                          'Resend',
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
    );
  }
}
