import 'package:example/lead_or_tail.dart';
import 'package:example/nester_item.dart';
import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

/// A app widget that shows how to use [ExpandableReorderableList].
class App extends StatelessWidget {
  /// A app widget that shows how to use [ExpandableReorderableList].
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Expandable reorderable list'),
        ),
        body: Builder(builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Home(),
          );
        }),
      ),
    );
  }
}

/// A sample widget that shows how to use [ExpandableReorderableList].
class Home extends StatefulWidget {
  /// A sample widget that shows how to use [ExpandableReorderableList].
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// The nested item that are displayed.
  final nestedItems = NestedItem.generate(depth: 3, width: 4);

  /// All the items.
  final nestedItemsMap = <String, NestedItem>{};

  final modelsController =
      ExpandableReorderableListItemModelController<ValueKey<String>>();

  @override
  void initState() {
    super.initState();
    nestedItemsMap.addAll(nestedItems.toMap());
  }

  /// It is called when an item is dragged and dropped.
  ///
  /// The `from` and `to` are the indexes of the items are available with
  /// [onReorderParam.oldIndex] and [onReorderParam.newIndex].
  void onReorder(OnReorderParam<ValueKey<String>> onReorderParam) {
    final item = onReorderParam.item;
    final nestedItem = nestedItemsMap[item.key.value]!;
    if (onReorderParam.oldIndex == 0) {
      // The first item is moved.
      // It is only a valid drag if:
      // - The item is collapsed
      // - The next item level is the same as the item level.
      if (!(modelsController.items[item.key]!.isCollapsed ||
          onReorderParam.newNextItem?.level == item.level)) {
        return;
      }
    }
    if (onReorderParam.newPreviousItem == null) {
      // The dragged item is moved at the first position.
      if (item.level != 0) {
        // The dragged item is not a top level item. This is not a valid drop.
        // If dropped at the first position, the item won't have a parent
        // anymore.
        return;
      }
      try {
        nestedItem.remove(modelsController);
        nestedItems.insert(0, nestedItem);
        setState(() {});
      } on StateError {
        // Invalid drag and drop operation.
      }
    } else {
      // The new previous item is not null.
      final newPreviousItem = onReorderParam.newPreviousItem!;
      final newPreviousNestedItem = nestedItemsMap[newPreviousItem.key.value]!;
      if (item.level == newPreviousItem.level) {
        // The item is moved after an item of the same level. It needs to be
        // inserted in the previous item's children just after the previous
        // item.
        try {
          nestedItem.remove(modelsController);
          newPreviousNestedItem.parent!.insert(
            newPreviousNestedItem.indexInParent + 1,
            nestedItem,
          );
          if (!modelsController.items[newPreviousItem.key]!.isCollapsed &&
              !modelsController.items[item.key]!.isCollapsed) {
            // The new previous item and the item are expanded. We need to pass
            // the new previous item's children to the moved item.
            nestedItem.children.addAll(newPreviousNestedItem.children);
            newPreviousNestedItem.children.clear();
          }
          setState(() {});
        } on StateError {
          // Invalid drag and drop operation.
        }
      } else if (item.level > newPreviousItem.level) {
        // The moved item is lower (visually) is the hierarchy than the previous item.
        if (item.level == newPreviousItem.level + 1) {
          nestedItem.remove(modelsController);
          if (modelsController.items[newPreviousItem.key]!.isCollapsed) {
            // Move the item at the end of the new previous item.
            newPreviousNestedItem.children.add(nestedItem);
          } else {
            // Move the item at the beginning of the new previous item.
            newPreviousNestedItem.insert(0, nestedItem);
          }
          setState(() {});
        } else {
          if (modelsController.items[newPreviousItem.key]!.isCollapsed) {
            // Add it to the very end.
            try {
              newPreviousNestedItem.addNested(nestedItem);
              nestedItem.remove(modelsController);
              setState(() {});
            } on StateError {
              // It was not a valid drag and drop.
            }
          } else {
            // Bad drag and drop, do nothing.
          }
        }
      } else {
        // The moved item is higher (visually) is the hierarchy than the previous item.
        if (onReorderParam.newNextItem == null) {
          // The item is dragged at the end of the list.
          // This is always a valid drop.
          nestedItem.remove(modelsController);
          nestedItems.addNested(nestedItem);
          setState(() {});
        } else {
          final newNextItem = onReorderParam.newNextItem!;
          final newNextNestedItem = nestedItemsMap[newNextItem.key.value]!;
          if (modelsController.items[item.key]!.isCollapsed) {
            // The item is collapsed.
            // Move it at the end of its new parent.
            var previousRelative = newPreviousNestedItem;
            while (previousRelative.level > nestedItem.level) {
              previousRelative = previousRelative.parent!;
            }
            final parent = previousRelative.parent!;
            var newIndex = previousRelative.indexInParent + 1;
            if (nestedItem.parent == parent &&
                nestedItem.indexInParent <= newIndex) {
              // The item is currently before the previous relative item. Since
              // the item is going to be removed, 1 needs to be subtracted from
              // `newIndex`.
              newIndex--;
            }
            nestedItem.remove(modelsController);
            parent.insert(
              previousRelative.indexInParent + 1,
              nestedItem,
            );
            setState(() {});
          } else {
            if (newNextItem.level > item.level + 1) {
              // This is not a valid drop.
              return;
            } else if (newNextItem.level <= item.level) {
              // Leave the item where it is.
              nestedItem.remove(modelsController);
              final parent = newNextNestedItem.parent!;
              parent.children[newNextNestedItem.indexInParent - 1]
                  .addNested(nestedItem);
              setState(() {});
            } else {
              // The new next item should be added to item.
              try {
                nestedItem.remove(modelsController);
              } on StateError {
                // Not a valid drop.
                return;
              }
              final previousRelative = newNextNestedItem.parent!;
              final parent = previousRelative.parent!;
              parent.insert(
                previousRelative.indexInParent + 1,
                nestedItem,
              );

              final newNextNestedItemIndexInParent =
                  newNextNestedItem.indexInParent;
              final newPreviousRelativeChildren =
                  previousRelative.children.sublist(
                0,
                newNextNestedItemIndexInParent,
              );
              final newChildren = previousRelative.children.sublist(
                newNextNestedItemIndexInParent,
                previousRelative.children.length,
              );
              previousRelative.children
                ..clear()
                ..addAll(newPreviousRelativeChildren);
              nestedItem.children
                ..clear()
                ..addAll(newChildren);
              setState(() {});
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandableReorderableList<ValueKey<String>>(
        leads: const [
          LeadOrTail(text: 'Header'),
        ],
        tails: const [
          LeadOrTail(text: 'Tail'),
        ],
        onReorder: onReorder,
        modelsController: modelsController,
        children: nestedItems.item.children,
      ),
    );
  }
}

/// An extension on [NestedItem] with helper methods.
extension on NestedItem {
  /// Remove an item from its parent and pass all its children to the previous
  /// item.
  void remove(
    ExpandableReorderableListItemModelController<ValueKey<String>>
        modelsController,
  ) {
    if (modelsController.items[item.key]!.isCollapsed || children.isEmpty) {
      // We move the children too.
      parent!.children.remove(this);
    } else {
      // Move only the header and not the children with it.
      final _indexInParent = indexInParent;
      if (_indexInParent == 0) {
        // We cannot move the children to the previous item, do nothing.
        throw StateError('Cannot remove the first item without its children.');
      }
      parent!.children[_indexInParent - 1].addAll(children);
      children.clear();
      parent!.children.remove(this);
    }
  }

  /// The associated item.
  ExpandableReorderableListItem<ValueKey<String>> get item {
    return ExpandableReorderableListItem<ValueKey<String>>(
      key: ValueKey<String>(name),
      children: children.map((child) => child.item).toList(),
      builder: (_, __, itemModel) => ItemWidget(
        name: name,
        level: level,
        itemModel: itemModel,
        hasChildren: children.isNotEmpty,
      ),
    );
  }

  /// Returns a map including the item and all its sub-items.
  Map<String, NestedItem> toMap() {
    final map = <String, NestedItem>{};
    map[name] = this;
    for (final child in children) {
      map.addAll(child.toMap());
    }
    return map;
  }

  /// Add recursively a new item to the list. If it is not possible, it will
  /// throw a [StateError].
  void addNested(NestedItem nestedItem) {
    assert(nestedItem.level > level);
    if (nestedItem.level == level + 1) {
      add(nestedItem);
    } else {
      if (children.isEmpty) throw StateError('No children');
      children.last.addNested(nestedItem);
    }
  }
}
