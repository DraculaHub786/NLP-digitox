import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/ui/transitions/default_page_transition_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppTheme {
  // Botanical fern seed — the app accents stay green by default and the
  // user's accent-color picker can still override `primary` via seedColor.
  static const _kSeedColor = Color(0xFF6E8460);

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
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.r.round(), g = color.g.round(), b = color.b.round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  static ThemeData darkTheme({Color? seedColor, required bool isAmoled}) {
    final base = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? _kSeedColor,
        brightness: Brightness.dark,
        surface: isAmoled ? DesignPalette.darkBg0 : DesignPalette.darkBg1,
      ),
    );

    return base.copyWith(
      pageTransitionsTheme: _kPageTransitionTheme,
      textTheme: base.textTheme.apply(fontFamily: 'Alice'),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Alice'),
      scaffoldBackgroundColor:
          isAmoled ? DesignPalette.darkBg0 : DesignPalette.darkBg1,
      extensions: [
        GlassTokens.dark,
        ElevationTokens.dark,
        SkeletonizerConfigData.dark(effect: _kShimmerEffect),
      ],
      // Botanical card theme with soft edges
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        ),
        color: DesignPalette.darkGlassFill,
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
        fillColor:
            isAmoled ? DesignPalette.darkGlassFill : DesignPalette.darkBg2,
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
        foregroundColor: DesignPalette.darkInk,
      ),
    );
  }

  static ThemeData lightTheme({Color? seedColor}) {
    final base = ThemeData.from(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? _kSeedColor,
        brightness: Brightness.light,
        surface: DesignPalette.lightBg0,
      ),
    );

    return base.copyWith(
      pageTransitionsTheme: _kPageTransitionTheme,
      textTheme: base.textTheme.apply(fontFamily: 'Alice'),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Alice'),
      scaffoldBackgroundColor: DesignPalette.lightBg0,
      extensions: [
        GlassTokens.light,
        ElevationTokens.light,
        SkeletonizerConfigData(effect: _kShimmerEffect),
      ],
      // Botanical card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        ),
        color: DesignPalette.lightGlassFill,
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
        fillColor: DesignPalette.lightBg2,
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
        foregroundColor: DesignPalette.lightInk,
      ),
    );
  }
}
