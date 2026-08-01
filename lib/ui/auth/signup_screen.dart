import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/ui/common/clay_widgets.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/transitions/default_effects.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0.0;
  List<String> _passwordIssues = [];

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Write a signup_events doc so n8n workflows can pick it up.
  Future<void> _writeSignupEvent({
    required String email,
    required String username,
  }) async {
    try {
      final uid = FirebaseAuthService.instance.userId;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('signup_events')
          .doc(uid)
          .set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
      debugPrint('✅ signup_events doc created for uid: $uid');
    } catch (e) {
      debugPrint('❌ Failed to queue signup event: $e');
      // Don't block signup on failure
    }
  }

  /// Show a one-time, skippable profile completion dialog for phone/age.
  Future<void> _showProfileCompletionDialog() async {
    final phoneController = TextEditingController();
    final ageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Optional — add your phone number and age for a more personalized experience.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (optional)',
                  hintText: '+1 234 567 8900',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age (optional)',
                  hintText: 'e.g. 25',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Skip for now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // If user filled in anything, save it to Firestore
    if (result == true || result == null) {
      final phone = phoneController.text.trim();
      final ageText = ageController.text.trim();
      if (phone.isNotEmpty || ageText.isNotEmpty) {
        try {
          final uid = FirebaseAuthService.instance.userId;
          if (uid != null) {
            final updates = <String, dynamic>{
              'profileCompletionPrompted': true,
              'lastUpdated': FieldValue.serverTimestamp(),
            };
            if (phone.isNotEmpty) updates['phoneNumber'] = phone;
            if (ageText.isNotEmpty) {
              final age = int.tryParse(ageText);
              if (age != null) updates['age'] = age;
            }
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update(updates);
            debugPrint('✅ Profile completion data saved');
          }
        } catch (e) {
          debugPrint('❌ Failed to save profile data: $e');
        }
      } else {
        // Mark as prompted so it doesn't show again
        try {
          final uid = FirebaseAuthService.instance.userId;
          if (uid != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update({
              'profileCompletionPrompted': true,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _signup() async {
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
      await FirebaseAuthService.instance.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      // Initialize Firestore user data for new user
      try {
        debugPrint('📝 Creating Firestore user data...');
        await FirestoreService.instance.initializeUserData(
          username: _nameController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          initialSettings: {
            'themeMode': 'system',
            'accentColor': 'Indigo',
            'locale': 'en',
            'protectedAccess': false,
            'isOnboardingDone': false,
          },
        );
        debugPrint('✅ Firestore user data created successfully!');
      } catch (e) {
        debugPrint('❌ Failed to create Firestore user data: $e');
        // Don't block signup if Firestore fails
      }

      // Initialize leaderboard data for new user
      try {
        debugPrint('📝 Creating leaderboard data for new user...');
        await LeaderboardService.instance.updateUserData(
          username: _nameController.text.trim(),
          points: 0,
          streak: 0,
          avatarEmoji: '👤',
          pointsBreakdown: {},
        );
        debugPrint('✅ Leaderboard data created successfully!');
      } catch (e) {
        debugPrint('❌ Failed to create leaderboard data: $e');
        // Don't block signup if leaderboard fails
      }

      // B.1: Write signup_events doc for n8n
      await _writeSignupEvent(
        email: _emailController.text.trim(),
        username: _nameController.text.trim(),
      );

      // B.3: Show optional profile completion (phone/age)
      await _showProfileCompletionDialog();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.onboardingPath,
        arguments: {"isOnboardingDone": false},
      );
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

  Future<void> _signupWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await FirebaseAuthService.instance.signInWithGoogle();

      // User cancelled — return silently
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final username = user.displayName ?? AppConstants.defaultUsername;

      // Initialize Firestore user data for Google sign-in users
      try {
        debugPrint('📝 Creating Firestore user data for Google user...');
        await FirestoreService.instance.initializeUserData(
          username: username,
          name: user.displayName ?? username,
          email: user.email,
          initialSettings: {
            'themeMode': 'system',
            'accentColor': 'Indigo',
            'locale': 'en',
            'protectedAccess': false,
            'isOnboardingDone': false,
          },
        );
        debugPrint('✅ Firestore user data created successfully!');
      } catch (e) {
        debugPrint('❌ Failed to create Firestore user data: $e');
        // Don't block signup if Firestore fails
      }

      // Initialize leaderboard data for Google sign-in users
      await LeaderboardService.instance.updateUserData(
        username: username,
        points: 0,
        streak: 0,
        avatarEmoji: '👤',
        pointsBreakdown: {},
      );

      // B.1: Write signup_events doc for n8n
      await _writeSignupEvent(
        email: user.email ?? '',
        username: username,
      );

      // B.3: Show optional profile completion (phone/age)
      await _showProfileCompletionDialog();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.onboardingPath,
        arguments: {"isOnboardingDone": false},
      );
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
          borderRadius: BorderRadius.circular(16),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// App logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 20.0),

                  /// Title
                  StyledText(
                    'Create Account',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    color: colorScheme.onSurface,
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 6.0),

                  StyledText(
                    'Sign up to get started with NLP digitox',
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    textAlign: TextAlign.center,
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 32.0),

                  /// Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: _modernFieldDecoration(
                      context,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: FluentIcons.person_20_regular,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 16.0),

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
                    onChanged: (value) {
                      _evaluatePasswordStrength(value);
                    },
                    decoration: _modernFieldDecoration(
                      context,
                      label: 'Password',
                      hint: 'Create a password',
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate(effects: DefaultEffects.transitionIn),

                  /// Password strength indicator
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

                  /// Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _modernFieldDecoration(
                      context,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: FluentIcons.lock_closed_20_regular,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? FluentIcons.eye_20_regular
                              : FluentIcons.eye_off_20_regular,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 28.0),

                  /// Sign up button
                  ClayContainer(
                    baseColor: colorScheme.primary,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: _isLoading ? null : _signup,
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ClayStyle.foregroundColor(
                                  colorScheme.primary,
                                ),
                              ),
                            )
                          : StyledText(
                              'Sign Up',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ClayStyle.foregroundColor(
                                colorScheme.primary,
                              ),
                            ),
                    ),
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 20.0),

                  /// Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: StyledText(
                          'OR',
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate(effects: DefaultEffects.transitionIn),

                  const SizedBox(height: 20.0),

                  /// Google sign-in button
                  OutlinedButton(
                    onPressed: _isLoading ? null : _signupWithGoogle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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

                  /// Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StyledText(
                        'Already have an account? ',
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
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
    );
  }
}
