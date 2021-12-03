import 'package:flutter/material.dart';

import 'expandable_reorderable_list_item.dart';
import 'expandable_reorderable_list_item_model.dart';

/// Callback method with [OnReorderParam] as a parameter.
typedef OnReorder<K extends Key> = void Function(
    OnReorderParam<K> onReorderParam);

/// Mixin handling the reorder of the AnimatedReorderableListView.
mixin OnReorderMixin<K extends Key> {
  /// The items tree.
  ExpandableReorderableListRootItem<K> get itemsTree;

  /// The Map of items.
  Map<K, ExpandableReorderableListItem<K>> get itemsMap;

  /// The controller of the items.
  late ExpandableReorderableListItemModelController<K> modelsController;

  /// Whether there are leads in the list.
  bool get hasLeads;

  /// Whether there are tails in the list.
  bool get hasTails;

  /// Number of children in the tree.
  ///
  /// This excludes the leads and tails.
  int get childrenNumber => itemsTree.itemCount;

  /// Returns [OnReorderParam] object for the callback function given as a
  /// parameter to the [ExpandableReorderableListView].
  OnReorderParam<K> onReorder(int oldIndex, int newIndex) {
    var updatedOldIndex = oldIndex; // Normalized old index
    var updatedNewIndex = newIndex; // Normalized new index
    if (hasLeads) {
      updatedOldIndex--;
      updatedNewIndex--;
    }
    if (hasTails) {
      if (newIndex > childrenNumber + 1) {
        updatedNewIndex--;
      }
    }
    // Index of the previous item
    final newPreviousItemIndex = updatedNewIndex - 1;

    final item = itemsTree.itemFromIndex(
        index: updatedOldIndex,
        modelsController: modelsController)!; // The moved item
    ExpandableReorderableListItem<K>?
        newPreviousItem; // The item before the moved item after the drop
    ExpandableReorderableListItem<K>?
        newNextItem; // The item after the moved item after the drop

    final newNextItemIndex = newPreviousItemIndex + 1;
    if (!(newPreviousItemIndex < 0)) {
      newPreviousItem = itemsTree.itemFromIndex(
          index: newPreviousItemIndex, modelsController: modelsController);
    }
    if (!(newNextItemIndex >= childrenNumber ||
        (newNextItemIndex == childrenNumber && hasTails))) {
      newNextItem = itemsTree.itemFromIndex(
          index: newNextItemIndex, modelsController: modelsController);
    }

    return OnReorderParam<K>(
      item: item,
      newPreviousItem: newPreviousItem,
      newNextItem: newNextItem,
      oldIndex: updatedOldIndex,
      newIndex: updatedNewIndex,
    );
  }
}

/// {@template novade.packages.expandable_reorderable_list.on_reorder_param}
/// The returned type of [OnReorderMixin.onReorder].
/// {@endtemplate}
class OnReorderParam<K extends Key> {
  /// {@macro novade.packages.expandable_reorderable_list.on_reorder_param}
  OnReorderParam({
    required this.item,
    required this.oldIndex,
    required this.newIndex,
    this.newPreviousItem,
    this.newNextItem,
  });

  /// The moved item.
  final ExpandableReorderableListItem<K> item;

  /// After the drop, the item just before the item in the list.
  ///
  /// Can be `null` if the item is dropped at the first position.
  final ExpandableReorderableListItem<K>? newPreviousItem;

  /// After the drop, the item just after the item in the list.
  ///
  /// Can be `null` if the item is dropped at the last position.
  final ExpandableReorderableListItem<K>? newNextItem;

  /// The old item index.
  final int oldIndex;

  /// The new item index.
  ///
  /// If the item is dropped at the first position, the new index is 0.
  final int newIndex;

  @override
  String toString() {
    return 'OnReorderParam(${item.key}: $oldIndex -> ${newPreviousItem?.key}: $newIndex)';
  }
}
