import 'package:flutter/material.dart';

/// Responsive utility class for handling screen-size based responsive design
/// without relying on flutter_screenutil
class ResponsiveUtils {
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get horizontal padding/width based on screen width
  /// For design size 375: value -> (value / 375) * screenWidth
  static double responsiveWidth(BuildContext context, double designValue) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (designValue / 375) * screenWidth;
  }

  /// Get vertical padding/height based on screen height
  /// For design size 812: value -> (value / 812) * screenHeight
  static double responsiveHeight(BuildContext context, double designValue) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (designValue / 812) * screenHeight;
  }

  /// Get responsive font size
  /// Scales font size proportionally to screen width
  /// min/max clamp to prevent extreme values
  static double responsiveFontSize(
    BuildContext context,
    double designValue, {
    double minSize = 8,
    double maxSize = 48,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaledSize = (designValue / 375) * screenWidth;
    return scaledSize.clamp(minSize, maxSize);
  }

  /// Get responsive radius for BorderRadius
  static double responsiveRadius(BuildContext context, double designValue) {
    return responsiveWidth(context, designValue);
  }

  /// Check if device is tablet (width >= 600)
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600;
  }

  /// Check if device is in landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive padding - horizontal
  static double responsivePaddingHorizontal(BuildContext context) {
    final width = screenWidth(context);
    if (isTablet(context)) {
      return width * 0.08; // 8% on tablets
    }
    return width * 0.05; // 5% on phones
  }

  /// Get responsive padding - vertical
  static double responsivePaddingVertical(BuildContext context) {
    final height = screenHeight(context);
    if (isLandscape(context)) {
      return height * 0.08;
    }
    return height * 0.05;
  }

  /// Helper to create responsive edge insets
  static EdgeInsets responsiveEdgeInsets({
    required BuildContext context,
    double horizontalDesignValue = 16,
    double verticalDesignValue = 16,
  }) {
    return EdgeInsets.symmetric(
      horizontal: responsiveWidth(context, horizontalDesignValue),
      vertical: responsiveHeight(context, verticalDesignValue),
    );
  }

  /// Helper to create responsive symmetric edge insets with only horizontal
  static EdgeInsets responsiveHorizontalEdgeInsets(
    BuildContext context,
    double designValue,
  ) {
    return EdgeInsets.symmetric(
      horizontal: responsiveWidth(context, designValue),
    );
  }

  /// Helper to create responsive symmetric edge insets with only vertical
  static EdgeInsets responsiveVerticalEdgeInsets(
    BuildContext context,
    double designValue,
  ) {
    return EdgeInsets.symmetric(
      vertical: responsiveHeight(context, designValue),
    );
  }
}

