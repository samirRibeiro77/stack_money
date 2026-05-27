import 'package:flutter/material.dart';

/// Core size and spacing constants for StackMoney.
/// Follows the 8-point grid system rule for flexible and responsive UI.
class AppSizes {
  // Prevent instantiation
  const AppSizes._();

  // --- Core Numeric Spacing Tokens ---
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;

  // --- Typography Font Sizes ---
  static const double fontSmall = 12.0;
  static const double fontBody = 14.0;
  static const double fontMedium = 16.0;
  static const double fontLarge = 20.0;
  static const double fontTitle = 24.0;
  static const double fontDisplay = 32.0;

  // --- Pre-built Constant Gaps (SizedBoxes) for Clean Layouts ---
  // Vertical Gaps
  static const SizedBox h4 = SizedBox(height: p4);
  static const SizedBox h8 = SizedBox(height: p8);
  static const SizedBox h12 = SizedBox(height: p12);
  static const SizedBox h16 = SizedBox(height: p16);
  static const SizedBox h24 = SizedBox(height: p24);
  static const SizedBox h32 = SizedBox(height: p32);
  static const SizedBox h48 = SizedBox(height: p48);

  // Horizontal Gaps
  static const SizedBox w4 = SizedBox(width: p4);
  static const SizedBox w8 = SizedBox(width: p8);
  static const SizedBox w12 = SizedBox(width: p12);
  static const SizedBox w16 = SizedBox(width: p16);
  static const SizedBox w24 = SizedBox(width: p24);
  static const SizedBox w32 = SizedBox(width: p32);

  // --- Border Radius ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}
