import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';

class StackMoneyTheme {
  // Pure Stealth & Cyberpunk Color Palette
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF141416);
  static const Color carbonGrey = Color(0xFF27272A);
  static const Color cyanNeon = Color(0xFF00F3FF);
  static const Color magentaNeon = Color(0xFFFF007F);
  static const Color platinumSilver = Color(0xFFE4E4E7);
  static const Color mutedGrey = Color(0xFF71717A);
  static const Color textPrimary = platinumSilver;

  static InputDecoration inputDecoration(
    String label, {
    Color color = StackMoneyTheme.cyanNeon,
    bool useUnderline = true,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: StackMoneyString.formatTitle(
        label,
        useUnderline: useUnderline,
      ),
      alignLabelWithHint: true,
      labelStyle: darkTheme.textTheme.bodySmall,
      floatingLabelStyle: darkTheme.textTheme.bodyLarge?.copyWith(
        color: readOnly ? color.withValues(alpha: 0.30) : color,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.x4,
        vertical: AppSizes.x5,
      ),
      constraints: const BoxConstraints(
        minHeight: AppSizes.x16,
        maxHeight: AppSizes.x16,
      ),
      suffixIcon: readOnly
          ? Icon(
              Icons.lock_outline_rounded,
              color: color.withValues(alpha: 0.40),
              size: AppSizes.x5,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.x3),
        borderSide: BorderSide(
          color: readOnly
              ? color.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.x3),
        borderSide: BorderSide(
          color: readOnly ? color.withValues(alpha: 0.30) : color,
          width: 1,
        ),
      ),
    );
  }

  static ButtonStyle get googleLoginButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: carbonGrey,
    foregroundColor: cyanNeon,
    elevation: 1,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.x10,
      vertical: AppSizes.x4,
    ),
    shape: const StadiumBorder(),
    textStyle: darkTheme.textTheme.titleSmall?.copyWith(
      fontWeight: AppTypography.weightBold,
    ),
  );

  static final _baseTextTheme = GoogleFonts.orbitronTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: textPrimary, displayColor: textPrimary);

  static ThemeData datePickerThemeOverride(BuildContext context) {
    return darkTheme.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: platinumSilver,
        onPrimary: background,
        secondary: mutedGrey,
        onSecondary: platinumSilver,
        surface: surface,
        onSurface: platinumSilver,
        error: magentaNeon,
      ),
      inputDecorationTheme: darkTheme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cyanNeon.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppSizes.x2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: cyanNeon, width: 1.5),
          borderRadius: BorderRadius.circular(AppSizes.x2),
        ),
        labelStyle: darkTheme.textTheme.bodySmall?.copyWith(
          color: cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),
        hintStyle: darkTheme.textTheme.bodySmall?.copyWith(color: carbonGrey),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: cyanNeon,
        secondary: magentaNeon,
        surface: surface,
        onSurface: textPrimary,
        error: magentaNeon,
      ),

      /// Text
      textTheme: _baseTextTheme.copyWith(
        // --- DISPLAY (Orbitron) ---
        displayLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplayLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingHuge,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplayMedium,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingHuge,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplaySmall,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingHuge,
        ),

        // --- HEADLINE (Orbitron) ---
        headlineLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineMedium,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineSmall,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),

        // --- TITLE (Orbitron) ---
        titleLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleLarge,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),
        titleMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleMedium,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),
        titleSmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleSmall,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
          letterSpacing: AppTypography.spacingLarge,
        ),

        // --- BODY (JetBrainsMono) ---
        bodyLarge: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodyLarge,
          fontWeight: AppTypography.weightNormal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodyMedium,
          fontWeight: AppTypography.weightNormal,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodySmall,
          fontWeight: AppTypography.weightNormal,
          color: textPrimary,
        ),

        // --- LABEL (JetBrainsMono) ---
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontLabelLarge,
          fontWeight: AppTypography.weightMedium,
          color: mutedGrey,
          letterSpacing: AppTypography.spacingTiny,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontLabelMedium,
          fontWeight: AppTypography.weightMedium,
          color: mutedGrey,
          letterSpacing: AppTypography.spacingTiny,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontLabelSmall,
          fontWeight: AppTypography.weightMedium,
          color: mutedGrey,
          letterSpacing: AppTypography.spacingTiny,
        ),
      ),

      ///  Date picker
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        elevation: 2,
        headerHelpStyle: _baseTextTheme.labelSmall,
        headerHeadlineStyle: _baseTextTheme.titleMedium?.copyWith(
          fontWeight: AppTypography.weightBold,
        ),
      ),

      /// App bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppSizes.min / 2,
        ),
      ),

      /// Tab bar
      tabBarTheme: TabBarThemeData(
        indicatorColor: cyanNeon,
        labelColor: magentaNeon,
        unselectedLabelColor: mutedGrey,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.bold,
          fontSize: AppTypography.fontBodyMedium,
        ),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodyMedium,
        ),
      ),

      /// Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: mutedGrey),
        floatingLabelStyle: const TextStyle(
          color: cyanNeon,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.x8,
          vertical: AppSizes.x8,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: magentaNeon, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: mutedGrey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: cyanNeon, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      /// Card theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: carbonGrey, width: AppSizes.min / 4),
        ),
      ),

      /// Divider
      dividerTheme: const DividerThemeData(color: carbonGrey),
    );
  }
}
