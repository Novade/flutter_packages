import 'package:flutter_test/flutter_test.dart';

import '../common_finders.dart';

export 'visibility_detector.dart';

/// Helper extension on [WidgetTester].
extension ItemWidgetTester on WidgetTester {
  /// Expect the given [items] to be in order.
  void expectOrdered(List<String> items) {
    var previousItemDy = 0.0;
    for (final item in items) {
      final finder = find.item(item);
      final itemDy = getCenter(finder).dy;
      expect(previousItemDy < itemDy, true);
      previousItemDy = itemDy;
    }
  }
}
