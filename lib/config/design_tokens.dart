import 'package:flutter/material.dart';

/// Static, theme-agnostic botanical palette extracted from the reference
/// images (Demo-light.png / Demo-dark.png). Surfaces stay botanical-neutral
/// so the user accent-color picker can still tint `primary` without
/// fighting the background.
abstract final class DesignPalette {
  // Light
  static const lightBg0 = Color(0xFFF6F3EA);
  static const lightBg1 = Color(0xFFEEECDD);
  static const lightBg2 = Color(0xFFDFE3CE);
  static const lightInk = Color(0xFF232A1F);
  static const lightSubInk = Color(0xFF5B6152);
  static const lightGlassFill = Color(0xFFFDFCF7);
  static const lightGlassBorder = Color(0xFFDDE1CD);
  static const lightShadow = Color(0xFF6B7350);

  // Dark (deep forest)
  static const darkBg0 = Color(0xFF121712);
  static const darkBg1 = Color(0xFF161D15);
  static const darkBg2 = Color(0xFF1B241B);
  static const darkInk = Color(0xFFECEFE4);
  static const darkSubInk = Color(0xFFA7B0A0);
  static const darkGlassFill = Color(0xFF1E251E);
  static const darkGlassBorder = Color(0xFF353F33);
  static const darkShadow = Color(0xFF000000);

  // Accents (shared)
  static const fern = Color(0xFF6E8460);
  static const fernDeep = Color(0xFF4F6344);
  static const sage = Color(0xFFA3B48E);
  static const terra = Color(0xFFC97B5F);
  static const terraSoft = Color(0xFFE0926F);
  static const gold = Color(0xFFC9A84C);
  static const berry = Color(0xFFB05B6A);

  // Cartoon-brutalist motivation card palette (deliberately distinct from
  // the botanical glass system — flat solid fills + bold outlines).
  static const funnyLightFill = Color(0xFFFFF3CD);
  static const funnyDarkFill = Color(0xFF2D2A1A);

  // Warm status/rank accents — keep saturated in both themes so streaks and
  // leaderboard medals pop against the botanical surfaces (matches reference
  // gold/terra accents).
  static const goldWarm = Color(0xFFF2B95C);
  static const goldDeep = Color(0xFFE09A2D);
  static const silverWarm = Color(0xFFC0C0C0);
  static const silverDeep = Color(0xFF808080);
  static const bronzeWarm = Color(0xFFCD7F32);
  static const bronzeDeep = Color(0xFF8B4513);
  static const streakFire = Color(0xFFE0926F);

  /// Gradient stops for the app background.
  static List<Color> backgroundGradient({required bool isDark}) =>
      isDark ? const [darkBg0, darkBg1, darkBg2] : const [lightBg0, lightBg1, lightBg2];

  static Color ink(bool isDark) => isDark ? darkInk : lightInk;
  static Color subInk(bool isDark) => isDark ? darkSubInk : lightSubInk;
}

/// Layered glass tokens: gradient fill + gradient border + soft tinted
/// shadow, all theme aware. This is the Guide 6 layered version.
@immutable
class GlassTokens extends ThemeExtension<GlassTokens> {
  final Color fillTop;
  final Color fillBottom;
  final Color borderTop;
  final Color borderBottom;
  final Color shadowColor;
  final double blurSigma;
  final Color statusGood;
  final Color statusWarn;
  final Color statusBad;

  const GlassTokens({
    required this.fillTop,
    required this.fillBottom,
    required this.borderTop,
    required this.borderBottom,
    required this.shadowColor,
    required this.blurSigma,
    required this.statusGood,
    required this.statusWarn,
    required this.statusBad,
  });

  static const radiusCard = 24.0;
  static const radiusPill = 999.0;

  static const light = GlassTokens(
    fillTop: Color(0xE6FDFCF7),
    fillBottom: Color(0xB3F0EFE2),
    borderTop: Color(0xFFFFFFFF),
    borderBottom: Color(0x99DDE1CD),
    shadowColor: DesignPalette.lightShadow,
    blurSigma: 18,
    statusGood: DesignPalette.fern,
    statusWarn: DesignPalette.gold,
    statusBad: DesignPalette.terra,
  );

  static const dark = GlassTokens(
    fillTop: Color(0xE6191F18),
    fillBottom: Color(0xB3141A13),
    borderTop: Color(0x594E5A47),
    borderBottom: Color(0x26353F33),
    shadowColor: DesignPalette.darkShadow,
    blurSigma: 20,
    statusGood: DesignPalette.sage,
    statusWarn: DesignPalette.gold,
    statusBad: DesignPalette.terraSoft,
  );

  LinearGradient get fillGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [fillTop, fillBottom],
      );

  LinearGradient get borderGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [borderTop, borderBottom],
      );

  static GlassTokens of(BuildContext context) =>
      Theme.of(context).extension<GlassTokens>() ?? light;

  @override
  GlassTokens copyWith({
    Color? fillTop,
    Color? fillBottom,
    Color? borderTop,
    Color? borderBottom,
    Color? shadowColor,
    double? blurSigma,
    Color? statusGood,
    Color? statusWarn,
    Color? statusBad,
  }) {
    return GlassTokens(
      fillTop: fillTop ?? this.fillTop,
      fillBottom: fillBottom ?? this.fillBottom,
      borderTop: borderTop ?? this.borderTop,
      borderBottom: borderBottom ?? this.borderBottom,
      shadowColor: shadowColor ?? this.shadowColor,
      blurSigma: blurSigma ?? this.blurSigma,
      statusGood: statusGood ?? this.statusGood,
      statusWarn: statusWarn ?? this.statusWarn,
      statusBad: statusBad ?? this.statusBad,
    );
  }

  @override
  GlassTokens lerp(ThemeExtension<GlassTokens>? other, double t) {
    if (other is! GlassTokens) return this;
    return GlassTokens(
      fillTop: Color.lerp(fillTop, other.fillTop, t)!,
      fillBottom: Color.lerp(fillBottom, other.fillBottom, t)!,
      borderTop: Color.lerp(borderTop, other.borderTop, t)!,
      borderBottom: Color.lerp(borderBottom, other.borderBottom, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      blurSigma: blurSigma + (other.blurSigma - blurSigma) * t,
      statusGood: Color.lerp(statusGood, other.statusGood, t)!,
      statusWarn: Color.lerp(statusWarn, other.statusWarn, t)!,
      statusBad: Color.lerp(statusBad, other.statusBad, t)!,
    );
  }
}

/// Named elevation map z1-z4 with soft, tinted shadows.
@immutable
class ElevationTokens extends ThemeExtension<ElevationTokens> {
  final List<BoxShadow> z1;
  final List<BoxShadow> z2;
  final List<BoxShadow> z3;
  final List<BoxShadow> z4;

  const ElevationTokens({
    required this.z1,
    required this.z2,
    required this.z3,
    required this.z4,
  });

  static const light = ElevationTokens(
    z1: [BoxShadow(color: Color(0x146B7350), offset: Offset(0, 2), blurRadius: 6)],
    z2: [BoxShadow(color: Color(0x1F6B7350), offset: Offset(0, 6), blurRadius: 16)],
    z3: [BoxShadow(color: Color(0x296B7350), offset: Offset(0, 12), blurRadius: 28)],
    z4: [BoxShadow(color: Color(0x336B7350), offset: Offset(0, 18), blurRadius: 40)],
  );

  static const dark = ElevationTokens(
    z1: [BoxShadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 6)],
    z2: [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 6), blurRadius: 16)],
    z3: [BoxShadow(color: Color(0x66000000), offset: Offset(0, 12), blurRadius: 28)],
    z4: [BoxShadow(color: Color(0x80000000), offset: Offset(0, 18), blurRadius: 40)],
  );

  static ElevationTokens of(BuildContext context) =>
      Theme.of(context).extension<ElevationTokens>() ?? light;

  List<BoxShadow> level(int elevationLevel) =>
      switch (elevationLevel) { 1 => z1, 2 => z2, 3 => z3, 4 => z4, _ => z1 };

  @override
  ElevationTokens copyWith({
    List<BoxShadow>? z1,
    List<BoxShadow>? z2,
    List<BoxShadow>? z3,
    List<BoxShadow>? z4,
  }) {
    return ElevationTokens(
      z1: z1 ?? this.z1,
      z2: z2 ?? this.z2,
      z3: z3 ?? this.z3,
      z4: z4 ?? this.z4,
    );
  }

  @override
  ElevationTokens lerp(ThemeExtension<ElevationTokens>? other, double t) {
    if (other is! ElevationTokens) return this;
    List<BoxShadow> lerpShadows(List<BoxShadow> a, List<BoxShadow> b) => [
          for (var i = 0; i < a.length && i < b.length; i++)
            BoxShadow.lerp(a[i], b[i], t)!,
        ];
    return ElevationTokens(
      z1: lerpShadows(z1, other.z1),
      z2: lerpShadows(z2, other.z2),
      z3: lerpShadows(z3, other.z3),
      z4: lerpShadows(z4, other.z4),
    );
  }
}

/// Typography roles for the botanical serif display system.
abstract final class DesignType {
  static const display = 'Alice';
  static const body = 'Alice';

  static TextStyle displayStyle(BuildContext context, {double size = 28}) =>
      Theme.of(context).textTheme.displaySmall!.copyWith(
            fontFamily: display,
            fontWeight: FontWeight.w600,
            fontSize: size,
            letterSpacing: 0.2,
            height: 1.15,
          );

  static TextStyle titleStyle(BuildContext context, {double size = 20}) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontFamily: display,
            fontWeight: FontWeight.w600,
            fontSize: size,
            letterSpacing: 0.2,
            height: 1.2,
          );
}
