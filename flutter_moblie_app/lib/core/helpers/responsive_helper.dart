import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600.0;

  /// Returns true if the screen width is less than 600px
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Returns true if the screen width is 600px or more
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  /// Recommended widths for tablet layouts
  static double get maxContentWidth => 800.0;
  static double get maxFormWidth => 500.0;
}
