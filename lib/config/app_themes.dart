// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/transitions/default_page_transition_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppTheme {
  // Modern gradient color scheme inspired by the reference UI
  static const _kSeedColor = Color(0xFF4DD6D9); // Turquoise/Cyan
  static const _kSecondaryColor = Color(0xFF2DD4BF); // Teal
  static const _kAccentColor = Color(0xFF60A5FA); // Light Blue

  static final _kShimmerEffect = ShimmerEffect(
    highlightColor: Colors.white.withValues(alpha: 0.6),
    baseColor: Colors.grey.withValues(alpha: 0.3),
  );

  /// Custom transition for page routes with smooth animations
  static const _kPageTransitionTheme = PageTransitionsTheme(
    builders: {TargetPlatform.android: DefaultPageTransitionsBuilder()},
  );

  static final materialColors = <String, MaterialColor>{
    'Turquoise': _createMaterialColor(const Color(0xFF4DD6D9)),
    'Teal': Colors.teal,
    'Cyan': Colors.cyan,
    'Light Blue': Colors.lightBlue,
    'Blue': Colors.blue,
    'Indigo': Colors.indigo,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Pink': Colors.pink,
    'Red': Colors.red,
    'Deep Orange': Colors.deepOrange,
    'Orange': Colors.orange,
    'Amber': Colors.amber,
    'Yellow': Colors.yellow,
    'Lime': Colors.lime,
    'Light Green': Colors.lightGreen,
    'Green': Colors.green,
    'Blue Grey': Colors.blueGrey,
    'Brown': Colors.brown,
    'Grey': Colors.grey,
  };

  /// Helper to create MaterialColor from Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static ThemeData darkTheme({Color? seedColor, required bool isAmoled}) =>
      ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor ?? _kSeedColor,
          brightness: Brightness.dark,
          surface: isAmoled ? Colors.black : const Color(0xFF0F172A), // Modern dark blue
        ),
      ).copyWith(
        pageTransitionsTheme: _kPageTransitionTheme,
        scaffoldBackgroundColor: isAmoled ? Colors.black : const Color(0xFF0F172A),
        extensions: [SkeletonizerConfigData.dark(effect: _kShimmerEffect)],
        // Modern card theme with elevation and rounded corners
        cardTheme: CardThemeData(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          color: isAmoled ? const Color(0xFF1A1A1A) : const Color(0xFF1E293B),
        ),
        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Modern input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isAmoled ? const Color(0xFF1A1A1A) : const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: seedColor ?? _kSeedColor,
              width: 2,
            ),
          ),
        ),
        // Modern app bar theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      );

  static ThemeData lightTheme({Color? seedColor}) => ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor ?? _kSeedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC), // Light blue-grey background
        ),
      ).copyWith(
        pageTransitionsTheme: _kPageTransitionTheme,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        extensions: [SkeletonizerConfigData(effect: _kShimmerEffect)],
        // Modern card theme
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          color: Colors.white,
        ),
        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Modern input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: seedColor ?? _kSeedColor,
              width: 2,
            ),
          ),
        ),
        // Modern app bar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
        ),
      );
}
