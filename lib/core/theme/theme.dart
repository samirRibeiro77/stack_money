import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/data/enum/action_button.dart';

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

  /// Custom ButtonStyle for the Quick Action Buttons (+ and -)
  /// Features a Platinum Silver background with high-contrast text/icons
  static ButtonStyle actionButton(ActionButton actionButton) {
    return _platinumActionButtonStyle.copyWith(
      foregroundColor: actionButton.color as WidgetStateProperty<Color>,
    );
  }

  static ButtonStyle get _platinumActionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: platinumSilver,
    elevation: 0,
    padding: const EdgeInsets.all(AppSizes.x4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.x8),
    ),
    textStyle: darkTheme.textTheme.labelMedium,
  );

  /// Custom ButtonStyle for the Google Login Button
  /// Features a Platinum Silver background, Cyan text, and stadium-rounded corners
  static ButtonStyle get googleLoginButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: carbonGrey,
    foregroundColor: cyanNeon,
    // Sets the text color to Cyan
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSizes.x10,
      vertical: AppSizes.x6,
    ),
    shape: const StadiumBorder(),
    // Makes the button perfectly rounded
    textStyle: darkTheme.textTheme.labelMedium,
  );

  /// Main Dark Theme Configuration for StackMoney
  static final _baseTextTheme = GoogleFonts.orbitronTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: textPrimary, displayColor: textPrimary);

  /// Main Dark Theme Configuration for StackMoney
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,

      // Base Color Scheme mapping
      colorScheme: const ColorScheme.dark(
        primary: cyanNeon,
        secondary: magentaNeon,
        surface: surface,
        onSurface: textPrimary,
        error: magentaNeon,
      ),

      // Global Typography Configurations
      textTheme: _baseTextTheme.copyWith(
        // --- DISPLAY (Orbitron) ---
        displayLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplayLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplayMedium,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontDisplaySmall,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),

        // --- HEADLINE (Orbitron) ---
        headlineLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineMedium,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontHeadlineSmall,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),

        // --- TITLE (Orbitron) ---
        titleLarge: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleMedium,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleSmall,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
        ),

        // --- BODY (JetBrainsMono) ---
        bodyLarge: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodyLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.jetBrainsMono(
          fontSize: AppTypography.fontBodyMedium,
          fontWeight: AppTypography.weightMedium,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: AppTypography.fontBodySmall,
          fontWeight: AppTypography.weightNormal,
          color: textPrimary,
        ),

        // --- LABEL (Orbitron) ---
        labelLarge: TextStyle(
          color: mutedGrey,
          fontSize: AppTypography.fontLabelLarge,
          fontWeight: AppTypography.weightMedium,
          fontFamily: 'Orbitron',
        ),
        labelMedium: TextStyle(
          color: mutedGrey,
          fontSize: AppTypography.fontLabelMedium,
          fontWeight: AppTypography.weightMedium,
          fontFamily: 'Orbitron',
        ),
        labelSmall: TextStyle(
          color: mutedGrey,
          fontSize: AppTypography.fontLabelSmall,
          fontWeight: AppTypography.weightMedium,
          fontFamily: 'Orbitron',
        ),
      ),

      // AppBar Customization with Orbitron Title
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: AppTypography.fontTitleLarge,
          fontWeight: AppTypography.weightBold,
          color: textPrimary,
          letterSpacing: AppSizes.min / 2,
        ),
      ),

      // Minimalist Navigation TabBar Configuration
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

      // Cyber-HUD Interactive TextFields Configuration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: mutedGrey),
        // Color of the label when it animates and floats to the border
        floatingLabelStyle: const TextStyle(
          color: cyanNeon,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.x8,
          vertical: AppSizes.x8,
        ),
        // Active/Focused Border Style (Lights up in Cyan)
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: magentaNeon, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        // Idle/Enabled Border Style (Discreet Muted Grey)
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: mutedGrey, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        // Error Border Style
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: cyanNeon, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Default Card Theme for Core Feature Containers
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(
            color: carbonGrey,
            width: AppSizes.min / 4,
          ), // Subtle border
        ),
      ),

      // Default Divider
      dividerTheme: DividerThemeData(color: Colors.white10),
    );
  }
}
