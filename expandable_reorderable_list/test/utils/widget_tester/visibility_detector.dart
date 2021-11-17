import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

extension VisibilityDetectorWidgetTester on WidgetTester {
  /// Default [Duration] for `tester.pumpAndSettle`
  static const defaultDuration = Duration(milliseconds: 100);

  Duration get updateInterval =>
      VisibilityDetectorController.instance.updateInterval == Duration.zero ? defaultDuration : VisibilityDetectorController.instance.updateInterval;

  /// Waits sufficiently long for the visibility callbacks to fire.
  Future<void> initWidgetTree({Duration duration = Duration.zero}) async {
    VisibilityDetectorController.instance.updateInterval = duration;
    await pump();
    await pumpAndSettle(updateInterval);
  }

  /// Replaces the widget tree with a [Placeholder] widget.  If `notifyNow` is
  /// `true`, fires [VisibilityDetector] callbacks immediately.  Otherwise waits
  /// sufficiently long for them to fire as normal.
  Future<void> clearWidgetTree({bool notifyNow = true}) async {
    await pumpWidget(const Placeholder());

    final controller = VisibilityDetectorController.instance;
    if (notifyNow) {
      controller.notifyNow();
    }
    await pump();
    await pumpAndSettle(updateInterval);
  }

  Future<void> waitVisibilityCallbacks({bool notify = true}) async {
    if (notify) {
      VisibilityDetectorController.instance.notifyNow();
    }
    await pump();
    await pump(updateInterval);
  }
}
