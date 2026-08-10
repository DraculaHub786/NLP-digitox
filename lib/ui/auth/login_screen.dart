import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/ui/common/pill_button.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/treated_background_image.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.instance.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Initialize leaderboard data if not exists (for existing users)
      try {
        final user = FirebaseAuthService.instance.currentUser;
        if (user != null) {
          debugPrint('🔍 Checking leaderboard data for user: ${user.uid}');
          final existingData = await LeaderboardService.instance.getCurrentUserData();
          if (existingData == null) {
            debugPrint('📝 No leaderboard data found, creating...');
            await LeaderboardService.instance.updateUserData(
              username: user.displayName ?? user.email?.split('@')[0] ?? 'User',
              points: 0,
              streak: 0,
              avatarEmoji: '👤',
              pointsBreakdown: {},
            );
            debugPrint('✅ Leaderboard data created successfully!');
          } else {
            debugPrint('✅ Leaderboard data already exists');
          }
        }
      } catch (e) {
        debugPrint('❌ Failed to initialize leaderboard: $e');
        // Don't block login if leaderboard fails
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.splashPath);
    } catch (e) {
      if (!mounted) return;
      context.showSnackAlert(
        e.toString().replaceAll('Exception: ', ''),
        icon: FluentIcons.error_circle_20_filled,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuthService.instance.signInWithGoogle();

      // Initialize leaderboard data if not exists (for existing users)
      final user = FirebaseAuthService.instance.currentUser;
      if (user != null) {
        final existingData = await LeaderboardService.instance.getCurrentUserData();
        if (existingData == null) {
          await LeaderboardService.instance.updateUserData(
            username: user.displayName ?? 'User',
            points: 0,
            streak: 0,
            avatarEmoji: '👤',
            pointsBreakdown: {},
          );
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.splashPath);
    } catch (e) {
      if (!mounted) return;
      context.showSnackAlert(
        e.toString().replaceAll('Exception: ', ''),
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
    final fillColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: colorScheme.onSurface.withValues(alpha: 0.6)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      border: border(borderColor, 1),
      enabledBorder: border(borderColor, 1),
      focusedBorder: border(colorScheme.primary, 1.5),
      errorBorder: border(colorScheme.error, 1),
      focusedErrorBorder: border(colorScheme.error, 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                    /// App icon — previous logo artwork shown on the first
                    /// page (login) alongside the animated splash.
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(GlassTokens.radiusCard),
                        border: Border.all(
                          color: GlassTokens.of(context).borderTop,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(GlassTokens.radiusCard),
                        child: Image.asset(
                          'assets/icon-prev.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 20.0),

                    /// Title
                    StyledText(
                      'Welcome Back',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      color: colorScheme.onSurface,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 6.0),

                    StyledText(
                      'Sign in to continue your digital detox journey',
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      textAlign: TextAlign.center,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 40.0),

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

                    const SizedBox(height: 16.0),

                    /// Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _modernFieldDecoration(
                        context,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: FluentIcons.lock_closed_20_regular,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? FluentIcons.eye_20_regular
                                : FluentIcons.eye_off_20_regular,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 28.0),

                    /// Login button
                    PillButton(
                      label: _isLoading ? null : 'Login',
                      onPressed: _isLoading ? null : _login,
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

                    const SizedBox(height: 20.0),

                    /// Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                          child: StyledText(
                            'OR',
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 20.0),

                    /// Google sign-in button
                    PillButton(
                      outlined: true,
                      fullWidth: true,
                      color: colorScheme.primary,
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.person_20_regular,
                            size: 20.0,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with Google',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 28.0),

                    /// Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StyledText(
                          "Don't have an account? ",
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushReplacementNamed(
                                    AppRoutes.signupPath,
                                  );
                                },
                          child: StyledText(
                            'Sign Up',
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
