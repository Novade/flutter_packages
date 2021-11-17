import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper extension on [CommonFinders].
extension ItemCommonFinder on CommonFinders {
  /// Find the item from its text key.
  Finder item(String item) {
    return descendant(
      of: byKey(Key(item)),
      matching: text('Item $item'),
    );
  }
}
