import 'package:flutter/material.dart';

/// {@template novade.packages.expandable_reorderable_list.collapse_callback}
/// A callback to call to collapse or expand an item.
///
/// - Call with `true` to collapse.
/// - Call with `false` to expand.
/// - Call with no parameter to switch the state.
/// {@endtemplate}
typedef CollapseCallback = void Function({bool? isCollapsed});

/// {@template novade.packages.expandable_reorderable_list.expandable_reorderable_list_item_model}
/// Model of an [ExpandableReorderableListItem].
/// {@endtemplate}
class ExpandableReorderableListItemModel extends ChangeNotifier {
  /// {@macro novade.packages.expandable_reorderable_list.expandable_reorderable_list_item_model}
  ExpandableReorderableListItemModel({
    this.collapseCallback,
    bool isCollapsed = false,
  }) : _isCollapsed = isCollapsed;

  /// {@macro novade.packages.expandable_reorderable_list.collapse_callback}
  final CollapseCallback? collapseCallback;

  /// Whether the item is collapsed or not.
  bool get isCollapsed => _isCollapsed;
  bool _isCollapsed;

  /// Set the state of the item.
  set isCollapsed(bool isCollapsed) {
    if (_isCollapsed != isCollapsed) {
      _isCollapsed = isCollapsed;
      Future.microtask(notifyListeners);
    }
  }

  /// The index of the item in the list.
  /// Includes the `lead` and `tail` of the list.
  int? get index => _index;
  int? _index;
  set index(int? index) {
    if (_index != index) {
      _index = index;
      Future.microtask(notifyListeners);
    }
  }
}

/// Controller for the models of the items.
class ExpandableReorderableListItemModelController<K extends Key> {
  final _items = <K, ExpandableReorderableListItemModel>{};

  /// Items' models.
  Map<K, ExpandableReorderableListItemModel> get items => _items;
}
