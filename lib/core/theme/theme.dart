import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/domain/data/enum/action_button.dart';

class StackMoneyTheme {
  // Pure Stealth & Cyberpunk Color Palette
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF141416);
  static const Color carbonGrey = Color(0xFF27272A);
  static const Color cyanNeon = Color(0xFF00F3FF);
  static const Color magentaNeon = Color(0xFFFF007F);
  static const Color platinumSilver = Color(0xFFE4E4E7);
  static const Color mutedGrey = Color(0xFF71717A);
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Custom ButtonStyle for the Quick Action Buttons (+ and -)
  /// Features a Platinum Silver background with high-contrast text/icons
  static ButtonStyle actionButton(ActionButton actionButton) {
    return _platinumActionButtonStyle.copyWith(
      foregroundColor: actionButton.color as WidgetStateProperty<Color>
    );
  }

  static ButtonStyle get _platinumActionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: platinumSilver,
    elevation: 0,
    padding: const EdgeInsets.all(AppSizes.x4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.x8),
    ),
    textStyle: GoogleFonts.jetBrainsMono(
      fontWeight: FontWeight.bold,
      fontSize: AppSizes.fontMedium,
    ),
  );

  /// Custom ButtonStyle for the Google Login Button
  /// Features a Platinum Silver background, Cyan text, and stadium-rounded corners
  static ButtonStyle get googleLoginButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: carbonGrey,
    foregroundColor: cyanNeon, // Sets the text color to Cyan
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10, vertical: AppSizes.x6),
    shape: const StadiumBorder(), // Makes the button perfectly rounded
    textStyle: GoogleFonts.jetBrainsMono(
      fontWeight: FontWeight.bold,
      fontSize: AppSizes.fontMedium,
      letterSpacing: AppSizes.min / 4,
    ),
  );

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
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.orbitron(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.orbitron(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.orbitron(color: textPrimary, fontWeight: FontWeight.w500),
      ),

      // AppBar Customization with Orbitron Title
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.orbitron(
          color: textPrimary,
          fontSize: AppSizes.fontLarge,
          fontWeight: FontWeight.bold,
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
          fontSize: AppSizes.fontBody,
        ),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: AppSizes.fontBody,
        ),
      ),

      // Cyber-HUD Interactive TextFields Configuration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(color: mutedGrey),
        // Color of the label when it animates and floats to the border
        floatingLabelStyle: const TextStyle(color: cyanNeon, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.x8, vertical: AppSizes.x8),
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
          side: const BorderSide(color: carbonGrey, width: AppSizes.min / 4), // Subtle border
        ),
      ),
    );
  }
}