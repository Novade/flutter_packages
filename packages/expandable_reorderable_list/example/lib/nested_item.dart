import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/material.dart';

/// {@template novade.packages.expandable_reorderable_list.ExpandableReorderableList}
/// Helper class to construct a tree of objects.
///
/// It has a list of children that can be empty and a parent that can be `null`
/// (if it is the root).
/// {@endtemplate}
class NestedItem with EquatableMixin {
  /// {@macro novade.packages.expandable_reorderable_list.ExpandableReorderableList}
  NestedItem({
    required this.name,
    required this.level,
    List<NestedItem>? children,
    this.parent,
  }) : children = children ?? [];

  /// Creates a tree of [NestedItem]s of a depth of [depth] and each node has
  /// [width] children.
  factory NestedItem.generate({
    required int depth,
    required int width,
  }) {
    return NestedItem._generate(
      depth: depth,
      width: width,
      position: [],
    );
  }

  /// Recursive factory to generate a tree of [NestedItem]s.
  ///
  /// Called by [NestedItem.generate].
  factory NestedItem._generate({
    required int depth,
    required int width,
    required List<int> position,
    NestedItem? parent,
  }) {
    final nestedItem = NestedItem(
      name: 'Item ${position.join("-")}',
      level: position.length,
      parent: parent,
    );
    final children = depth <= position.length
        ? <NestedItem>[]
        : List<NestedItem>.generate(
            width,
            (index) => NestedItem._generate(
              depth: depth,
              width: width,
              position: position + [index],
              parent: nestedItem,
            ),
          );
    return nestedItem..children.addAll(children);
  }

  /// The name of the item.
  final String name;

  /// Its level in the tree.
  /// `0` for the root.
  final int level;

  /// Its children.
  ///
  /// Can be empty.
  final List<NestedItem> children;

  /// The parent of the item.
  ///
  /// Can be `null` if it is the root.
  NestedItem? parent;

  @override
  List<Object> get props => [name, level];

  /// Index of the item in the list of children of its parent.
  int get indexInParent {
    if (parent == null) {
      throw Exception("This item has no parent");
    } else {
      return parent!.children.indexWhere((child) => child.name == name);
    }
  }

  /// Insert the [item] at the specified [index].
  void insert(int index, NestedItem item) {
    children.insert(index, item);
    item.parent = this;
  }

  /// Add an [Iterable] of items at the end of the children.
  void addAll(Iterable<NestedItem> items) {
    children.addAll(items);
    for (final item in items) {
      item.parent = this;
    }
  }

  /// Add the [item] at the end of the children list.
  void add(NestedItem item) {
    children.add(item);
    item.parent = this;
  }
}

/// Widget to display a [NestedItem].
class ItemWidget extends StatelessWidget {
  /// Widget to display a [NestedItem].
  const ItemWidget(
      {required this.name,
      required this.level,
      required this.itemModel,
      required this.hasChildren,
      Key? key})
      : super(key: key);

  /// The name displayed.
  final String name;

  /// The level in the tree.
  final int level;

  /// The item model.
  final ExpandableReorderableListItemModel itemModel;

  /// Whether or not the item has children.
  final bool hasChildren;

  /// Color of the item.
  ///
  /// The more the item is nested, the whiter it is.
  Color get color {
    return Color(
      0xffffffff - ((exp((-level + 1)) * 0x80).toInt() * 0x00010101),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: itemModel.index!,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Theme(
          data: Theme.of(context).copyWith(
            shadowColor: const Color(0xff000000),
          ),
          child: Card(
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: 40,
                ),
                child: Row(
                  children: [
                    SizedBox(width: level * 8),
                    Text(
                      name,
                      style: TextStyle(
                        // Indent the text to make it look like a tree.
                        fontSize: 16 + 16 * pow(0.5, level).toDouble(),
                      ),
                    ),
                    const Spacer(),
                    if (hasChildren)
                      IconButton(
                        icon: Icon(
                          itemModel.isCollapsed
                              ? Icons.expand_more
                              : Icons.expand_less,
                        ),
                        onPressed: () {
                          itemModel.collapseCallback!();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
