
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';
import 'package:nlp_digitox/ui/common/modern_background.dart';
import 'package:nlp_digitox/ui/common/glass_widgets.dart';
import 'package:nlp_digitox/ui/common/glassmorphic_container.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: ModernGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Modern App Logo with gradient
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        FluentIcons.brain_circuit_20_filled,
                        size: 50.0,
                        color: Colors.white,
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),
                    
                    const SizedBox(height: 24.0),

                    /// Title with gradient text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ).createShader(bounds),
                      child: const StyledText(
                        'Welcome Back',
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                        color: Colors.white,
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 8.0),

                    StyledText(
                      'Sign in to continue your digital detox journey',
                      fontSize: 16,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                      textAlign: TextAlign.center,
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 48.0),

                    /// Email Field with glass effect
                    GlassTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      prefixIcon: FluentIcons.mail_20_regular,
                      keyboardType: TextInputType.emailAddress,
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

                    const SizedBox(height: 20.0),

                    /// Password Field with glass effect
                    GlassTextField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      prefixIcon: FluentIcons.lock_closed_20_regular,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? FluentIcons.eye_20_regular
                              : FluentIcons.eye_off_20_regular,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
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

                    const SizedBox(height: 32.0),

                    /// Modern Login Button with glass effect
                    GlassButton(
                      onPressed: _isLoading ? null : _login,
                      width: double.infinity,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 24.0),

                    /// Divider with glass effect
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GlassmorphicContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            borderRadius: 12,
                            opacity: 0.05,
                            blur: 5,
                            enableBorder: false,
                            child: StyledText(
                              'OR',
                              fontSize: 12,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white60
                                  : Colors.black45,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 24.0),

                    /// Google Sign In Button with outlined glass effect
                    GlassButton(
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      width: double.infinity,
                      isOutlined: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.person_20_regular,
                            size: 20.0,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ).animate(effects: DefaultEffects.transitionIn),

                    const SizedBox(height: 32.0),

                    /// Sign Up Link with glass background
                    GlassmorphicContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      opacity: 0.05,
                      blur: 10,
                      enableBorder: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StyledText(
                            "Don't have an account? ",
                            fontSize: 14,
                            color: theme.brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
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
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
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
