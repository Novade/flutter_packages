import 'package:flutter_test/flutter_test.dart';

import 'common_finders.dart';

/// Expects a list of [items] to match the given [matcher].
///
/// The items values must be equal to the generated keys by [BuildTreeInput]
/// (eg: '1.0', '1.1', '1.2', ...).
void expectItems(List<String> items, dynamic matcher) {
  for (final item in items) {
    expect(find.item(item), matcher);
  }
}
