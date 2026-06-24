/// Core size and spacing constants for StackMoney.
/// Follows the 8-point grid system rule for flexible and responsive UI.
class AppSizes {
  // Prevent instantiation
  const AppSizes._();

  // --- Core Numeric Spacing Tokens ---
  static const double min = 2.0;
  static const double x2 = min * 2;
  static const double x3 = min * 3;
  static const double x4 = min * 4;
  static const double x5 = min * 5;
  static const double x6 = min * 6;
  static const double x7 = min * 7;
  static const double x8 = min * 8;
  static const double x9 = min * 9;
  static const double x10 = min * 10;
  static const double x12 = min * 12;
  static const double x16 = min * 16;
  static const double x17 = min * 17;
  static const double x20 = min * 20;
  static const double x24 = min * 24;
  static const double x26 = min * 26;
  static const double x30 = min * 30;
  static const double max = min * 32;

  /// SizedBox
  static const double sizedBoxSmall = 8.0;
  static const double sizedBoxMedium = 12.0;
  static const double sizedBoxLarge = 16.0;

  /// --- Border Radius ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  /// --- NavBar Sizes ---
  static const double navBarHeight = 60.0;
  static const double navBarPaddingBottom = 30.0;
  static const double navBarRadius = 64.0;
  static const double navBarIconSize = 20.0;
  static const double navBarContentPadding = 100.0;

  /// --- Dropdown ---
  static const double dropdownWidth = 80;

  /// --- Sticky Hud ---
  static const double stickyHudMinExtent = 30;
  static const double stickyHudMinExtentMultiplier = 18;
  static const double stickyHudMaxExtent = 75;
  static const double stickyHudMaxExtentMultiplier = 32;
}
