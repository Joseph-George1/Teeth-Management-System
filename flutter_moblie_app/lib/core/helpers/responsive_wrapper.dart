import 'package:flutter/material.dart';
import 'responsive_helper.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool bypass;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.bypass = false,
  });

  @override
  Widget build(BuildContext context) {
    if (bypass || ResponsiveHelper.isMobile(context)) {
      return child;
    }

    final actualMaxWidth = maxWidth ?? ResponsiveHelper.maxContentWidth;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: actualMaxWidth,
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: Size(
              MediaQuery.of(context).size.width.clamp(0, actualMaxWidth),
              MediaQuery.of(context).size.height,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A simple InheritedWidget to toggle responsiveness globally if needed
class ResponsiveConfig extends InheritedWidget {
  final bool isFullWidth;

  const ResponsiveConfig({
    super.key,
    required this.isFullWidth,
    required super.child,
  });

  static ResponsiveConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResponsiveConfig>();
  }

  @override
  bool updateShouldNotify(ResponsiveConfig oldWidget) {
    return isFullWidth != oldWidget.isFullWidth;
  }
}
