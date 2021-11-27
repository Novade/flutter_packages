import 'dart:math';

import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/material.dart';

class BuildTreeInput {
  const BuildTreeInput([this.children = const []]);

  final List<BuildTreeInput> children;

  ExpandableReorderableListRootItem<Key> toTree() {
    return ExpandableReorderableListRootItem<Key>(
      children: children.toItems(),
    );
  }
}

extension _BuildTreeInputListExtension on List<BuildTreeInput> {
  List<ExpandableReorderableListItem<Key>> toItems(
      [List<int> position = const []]) {
    return asMap().entries.map((entry) {
      final currentPosition = [...position, entry.key];
      return ExpandableReorderableListItem<Key>(
        key: Key(currentPosition.join('.')),
        builder: (_, child, model) {
          return ReorderableDragStartListener(
            index: model.index!,
            child: child!,
          );
        },
        child: ItemWidget(
          position: currentPosition,
        ),
        children: entry.value.children.toItems(currentPosition),
      );
    }).toList();
  }
}

/// An item built in the [ExpandableReorderableListView].
class ItemWidget extends StatelessWidget {
  const ItemWidget({
    required this.position,
    Key? key,
  }) : super(key: key);

  /// The position of the item.
  final List<int> position;

  /// The min height of the item.
  ///
  /// This doesn't include the [Card] margin.
  static const kMinHeight = 16;

  /// Get the height of the item from its level in the tree.
  ///
  /// Set [margin] to `false` to not include the [Card] margin.
  static double heightFromLevel(int level, {bool margin = true}) {
    assert(level > 0);
    return (kMinHeight + (kMinHeight * (pow(0.5, level - 1)))).toDouble() +
        (margin ? 2 * ItemWidget.margin : 0);
  }

  /// The [Card] margin.
  static const margin = 2.0;

  /// The height of the item excluding the [Card] margin.
  double get height => heightFromLevel(position.length, margin: false);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(margin),
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: position.length * 8),
        alignment: Alignment.centerLeft,
        child: Text(
          'Item ${position.join('.')}',
        ),
      ),
    );
  }
}
