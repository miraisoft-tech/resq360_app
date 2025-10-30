import 'package:flutter/material.dart';

/// Safely pops any existing route (like a dialog) before navigating.
/// Prevents Flutter `_debugLocked` or `_RouteLifecycle.popping` errors.
class NavigationHelper {
  static Future<void> popAndNavigate(
    BuildContext context,
    Widget destination, {
    bool replace = false,
    bool rootNavigator = true,
    Duration delay = const Duration(milliseconds: 150),
  }) async {
    // If a dialog or route can be popped, close it first.
    final navigator = Navigator.of(context, rootNavigator: rootNavigator);
    if (navigator.canPop()) {
      navigator.pop();
      // Give the navigator time to unlock before pushing again
      await Future<void>.delayed(delay);
    }

    // Decide whether to replace or push
    if (replace) {
      await navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => destination,
        ),
      );
    } else {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => destination,
        ),
      );
    }
  }

  /// Just a safe pop with an optional delay.
  static Future<void> safePop(
    BuildContext context, {
    bool rootNavigator = true,
    Duration delay = const Duration(milliseconds: 150),
  }) async {
    final navigator = Navigator.of(context, rootNavigator: rootNavigator);
    if (navigator.canPop()) {
      navigator.pop();
      await Future<void>.delayed(delay);
    }
  }
}
