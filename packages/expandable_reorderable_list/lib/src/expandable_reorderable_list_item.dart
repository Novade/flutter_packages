import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'expandable_reorderable_list_item_model.dart';

/// {@template novade.packages.expandable_reorderable_list.expandable_reorderable_list_tree_item}
/// An element of the item tree.
/// {@endtemplate}
abstract class ExpandableReorderableListTreeItem<K extends Key>
    with EquatableMixin {
  /// {@macro novade.packages.expandable_reorderable_list.expandable_reorderable_list_tree_item}
  ExpandableReorderableListTreeItem({
    List<ExpandableReorderableListItem<K>>? children,
  }) : children = children ?? <ExpandableReorderableListItem<K>>[];

  /// Children of the item.
  final List<ExpandableReorderableListItem<K>> children;

  /// Whether the item has children or not.
  bool get hasChildren => children.isNotEmpty;

  /// A unique Key used in in the [ReorderableListView].
  K get key;

  /// The parent of the item if it has one.
  ExpandableReorderableListTreeItem<K>? get parent => _parent;
  ExpandableReorderableListTreeItem<K>? _parent;

  /// The level of the item in the reorderable list.
  ///
  /// The root item has a level of 0.
  int get level => _level;
  late int _level;

  /// Number of items in the all subtree.
  int get itemCount => _itemCount;
  late int _itemCount;

  /// The total total number of visible items.
  int _visibleItemCount(
      ExpandableReorderableListItemModelController<K> modelsController) {
    if (modelsController.items[key]?.isCollapsed ?? false) {
      return 0;
    }
    return __visibleItemCount(modelsController);
  }

  int __visibleItemCount(
      ExpandableReorderableListItemModelController<K> modelsController) {
    return children.fold<int>(
        children.length,
        (previousValue, child) =>
            previousValue + child._visibleItemCount(modelsController));
  }

  ExpandableReorderableListTreeItem<K>? _itemFromIndex({
    required int index,
    required ExpandableReorderableListItemModelController<K> modelsController,
    int current = 0,
  }) {
    assert(index >= 0);
    var _current = current;
    if (index == _current) return this;
    _current++;
    for (final child in children) {
      final childItemCount = child._visibleItemCount(modelsController) + 1;
      if (_current + childItemCount > index)
        return child._itemFromIndex(
            index: index,
            modelsController: modelsController,
            current: _current);
      _current += childItemCount;
    }
    return null;
  }

  /// Init the item in the items tree.
  void _initItem({
    /// The current level in the items tree.
    int level = 0,

    /// The parent of the item in the items tree.
    ExpandableReorderableListTreeItem<K>? parent,
  }) {
    _level = level;
    _parent = parent;
    _itemCount = children.length;
    for (final child in children) {
      child._initItem(
        level: level + 1,
        parent: this,
      );
      _itemCount += child._itemCount;
    }
  }

  @override
  List<Object?> get props => [key];

  /// Get the position of the item in its parents.
  ///
  /// Returns an empty list `<int>[]` if it doesn't have any parent (root item).
  /// The position of the item in its first parent is `positions.last`.
  List<int> get positions {
    return _getPositions();
  }

  /// Recursive function to accumulate the position of each item in its parent.
  List<int> _getPositions([List<int>? currentPositions]) {
    currentPositions ??= <int>[];
    if (this is ExpandableReorderableListItem<K>) {
      final index =
          parent!.children.indexOf(this as ExpandableReorderableListItem<K>);
      currentPositions.insert(0, index);
      return parent!._getPositions(currentPositions);
    } else {
      return currentPositions;
    }
  }

  /// The parents in the item tree.
  List<ExpandableReorderableListItem<K>> get parents => _getParents();

  /// Recursive function to get the parents.
  List<ExpandableReorderableListItem<K>> _getParents(
      [List<ExpandableReorderableListItem<K>>? currentParents]) {
    currentParents ??= <ExpandableReorderableListItem<K>>[];
    if (parent is ExpandableReorderableListItem<K>) {
      final castedParent = parent! as ExpandableReorderableListItem<K>;
      currentParents.insert(0, castedParent);
      return castedParent._getParents(currentParents);
    } else {
      return currentParents;
    }
  }
}

/// {@template novade.packages.expandable_reorderable_list.expandable_reorderable_list_item_builder}
/// Builder callback to build the item.
/// {@endtemplate}
typedef ExpandableReorderableListItemBuilder = Widget Function(
    BuildContext, Widget?, ExpandableReorderableListItemModel);

/// {@template novade.packages.expandable_reorderable_list.expandable_reorderable_list_item}
/// Item of the [AnimatedReorderableListView].
/// {@endtemplate}
class ExpandableReorderableListItem<K extends Key>
    extends ExpandableReorderableListTreeItem<K> with EquatableMixin {
  ///  {@macro novade.packages.expandable_reorderable_list.expandable_reorderable_list_item}
  ExpandableReorderableListItem({
    required this.key,
    ExpandableReorderableListItemBuilder? builder,
    this.child,
    List<ExpandableReorderableListItem<K>>? children,
  })  : assert(builder != null || child != null,
            'child or builder must be specified'),
        builder = builder ?? _defaultBuilder,
        super(children: children);

  /// A [Widget] that doesn't need to be rebuilt.
  final Widget? child;

  @override
  final K key;

  /// {@macro novade.packages.expandable_reorderable_list.expandable_reorderable_list_item_builder}
  final ExpandableReorderableListItemBuilder builder;

  /// Builder that returns the [child] if as a non nullable [Widget].
  static Widget _defaultBuilder(BuildContext context, Widget? child,
          ExpandableReorderableListItemModel model) =>
      child!;
}

/// {@template novade.packages.expandable_reorderable_list.expandable_reorderable_list_root_item}
/// The root item of the item tree.
/// {@endtemplate}
class ExpandableReorderableListRootItem<K extends Key>
    extends ExpandableReorderableListTreeItem<K> {
  /// {@macro novade.packages.expandable_reorderable_list.expandable_reorderable_list_root_item}
  ExpandableReorderableListRootItem({
    List<ExpandableReorderableListItem<K>>? children,
  }) : super(children: children) {
    _initItem(level: -1);
  }

  /// A root cannot have a parent.
  @override
  ExpandableReorderableListTreeItem<K>? get parent => null;

  @override
  int get level => -1;

  @override
  K get key => throw Exception('The root item does not have a key');

  /// The total number of visible items.
  int visibleItemCount(
          ExpandableReorderableListItemModelController<K> modelsController) =>
      __visibleItemCount(modelsController);

  /// Get the item in the tree from its visible index.
  ExpandableReorderableListItem<K>? itemFromIndex({
    required int index,
    required ExpandableReorderableListItemModelController<K> modelsController,
  }) {
    return _itemFromIndex(
        index: index,
        modelsController: modelsController,
        current: -1) as ExpandableReorderableListItem<K>?;
  }
}
