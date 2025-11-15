// lib/utils/responsive_values.dart

import 'package:flutter/material.dart';

mixin ResponsiveValues {
  // Use late final for screen dimensions, initialized once in the build process.
  late final double screenWidth;
  late final double screenHeight;

  /// Initializes the screen dimensions from the provided context.
  void initialize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }

  // --- 1. Breakpoints ---
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;

  // --- 8. Dynamic Padding/Spacing (Fallback/General Use) ---
  /// Calculates screen padding (horizontal: 4% width, vertical: 2% height).
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      );

  /// Calculates a general dynamic spacing value.
  double get dynamicSpacing {
    return isDesktop
        ? screenWidth * 0.02
        : isTablet
            ? screenWidth * 0.015
            : screenWidth * 0.03;
  }

  // --- Card/Text Scaling ---
  /// Calculates the recommended title font size (width * 0.038).
  double get titleFontSize => screenWidth * 0.038;

  /// Calculates the recommended icon size (width * 0.05).
  double get iconSize => screenWidth * 0.05;
}
