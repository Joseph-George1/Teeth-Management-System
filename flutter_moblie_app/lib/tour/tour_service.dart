import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'multi_tour_widget.dart';

import 'tour_config.dart';

/// Manages the one-time onboarding tour for a given screen.
///
/// Uses SharedPreferences with keys `tour_seen_<elementId>` to ensure
/// each tooltip is shown only once, ever, across app sessions.
class TourService {
  TourService._();

  /// Key prefix used in SharedPreferences.
  static const String _prefix = 'tour_seen_';

  // ── Public API ───────────────────────────────────────────────────────────

  /// Call this in the screen's `initState` (inside a post-frame callback)
  /// to start the tour for the given [screenName].
  ///
  /// Only unseen steps will be shown. If all steps have been seen,
  /// nothing happens.
  ///
  /// The [context] must be a descendant of [ShowCaseWidget].
  static Future<void> startTourForScreen(
    BuildContext context,
    String screenName,
  ) async {
    final groups = TourConfig.stepGroupsForScreen(screenName);
    if (groups.isEmpty) return;

    final unseenGroups = <List<TourStep>>[];
    final prefs = await SharedPreferences.getInstance();

    for (final group in groups) {
      final unseenStepsInGroup = <TourStep>[];
      for (final step in group) {
        final seen = prefs.getBool('$_prefix${step.id}') ?? false;
        if (!seen) {
          unseenStepsInGroup.add(step);
        }
      }
      if (unseenStepsInGroup.isNotEmpty) {
        unseenGroups.add(unseenStepsInGroup);
      }
    }

    if (unseenGroups.isEmpty) return;

    // Longer delay on tablets so drawer/layout is fully measured before showcase.
    if (!context.mounted) return;
    final delayMs = MediaQuery.sizeOf(context).width > 600 ? 900 : 500;

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!context.mounted) return;
      try {
        final tourWidget = MultiTourWidget.of(context);
        if (tourWidget != null) {
          tourWidget.startTour(unseenGroups);
          return;
        }
        final keys =
            unseenGroups.expand((g) => g).map((s) => s.key).toList();
        if (keys.isEmpty) return;
        ShowCaseWidget.of(context).startShowCase(keys);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('[TourService] Failed to start $screenName: $e\n$st');
        }
      }
    });
  }

  /// Marks a single step as seen so it won't appear again.
  static Future<void> markSeen(String stepId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$stepId', true);
  }

  /// Checks whether a specific step has been seen.
  static Future<bool> hasBeenSeen(String stepId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$stepId') ?? false;
  }

  /// Marks all steps as seen to skip the entire tour.
  static Future<void> skipAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final step in TourConfig.allSteps) {
      await prefs.setBool('$_prefix${step.id}', true);
    }
  }

  /// Resets all tour progress (useful for testing / debugging).
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final step in TourConfig.allSteps) {
      await prefs.remove('$_prefix${step.id}');
    }
  }

  /// Returns the [TourStep] matching the given [key], or null.
  static TourStep? stepForKey(GlobalKey key) {
    try {
      return TourConfig.allSteps.firstWhere((s) => s.key == key);
    } catch (_) {
      return null;
    }
  }

  /// Builds the standard `onTargetClick` callback that marks the step
  /// as seen and dismisses the tooltip.
  static VoidCallback onDismiss(GlobalKey key) {
    return () {
      final step = stepForKey(key);
      if (step != null) {
        markSeen(step.id);
      }
    };
  }
}
