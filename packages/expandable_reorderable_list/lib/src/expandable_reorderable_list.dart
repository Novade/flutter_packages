import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'expandable_reorderable_list_item.dart';
import 'expandable_reorderable_list_item_model.dart';
import 'on_reorder_mixin.dart';

/// Lead or Tail of the [ExpandableReorderableList].
enum _LeadTail {
  /// Lead. It is the first item of the list.
  lead,

  /// Tail. It is the last item of the list.
  tail,
}

/// {@template novade.package.expandable_reorderable_list.expandable_reorderable_list}
/// An expandable reorderable list.
///
/// If `onReorder` is specified, it builds a [ReorderableListView], if not, it
/// builds a [ListView].
///
/// ---
///
/// This example, inspired by the [ReorderableListView] documentation, creates a
/// list using [ExpandableReorderableList]:
///
/// ```dart
///  final List<int> _items = List<int>.generate(50, (index) => index);
///
///  @override
///  Widget build(BuildContext context) {
///    final colorScheme = Theme.of(context).colorScheme;
///    final oddItemColor = colorScheme.primary.withOpacity(0.05);
///    final evenItemColor = colorScheme.primary.withOpacity(0.15);
///    return ExpandableReorderableList<ValueKey<int>>(
///      onReorder: (onReorderParam) {
///        setState(() {
///          var newIndex = onReorderParam.newIndex;
///          if (onReorderParam.oldIndex < onReorderParam.newIndex) {
///            newIndex -= 1;
///          }
///          final int item = _items.removeAt(onReorderParam.oldIndex);
///          _items.insert(newIndex, item);
///        });
///      },
///      children: _items.map((int item) {
///        return ExpandableReorderableListItem<ValueKey<int>>(
///          key: ValueKey<int>(item),
///          builder: (_, child, model) {
///            return ReorderableDragStartListener(
///              index: model.index!,
///              child: ListTile(
///                title: Text('Item $item'),
///                tileColor: item.isOdd ? oddItemColor : evenItemColor,
///              ),
///            );
///          },
///        );
///      }).toList(),
///    );
///  }
/// ```
/// {@endtemplate}
class ExpandableReorderableList<K extends Key> extends StatefulWidget {
  /// {@macro novade.package.expandable_reorderable_list.expandable_reorderable_list}
  ExpandableReorderableList({
    this.leads = const <Widget>[],
    this.tails = const <Widget>[],
    List<ExpandableReorderableListItem<K>>? children,
    this.onReorder,
    this.scrollController,
    this.modelsController,
    this.scrollDirection = Axis.vertical,
    Key? key,
  })  : children = children ?? <ExpandableReorderableListItem<K>>[],
        super(key: key);

  /// Leading widgets that cannot be reordered. They are always visible.
  final List<Widget> leads;

  /// Trailing widgets that cannot be reordered. They are always visible.
  final List<Widget> tails;

  /// Children of the [ExpandableReorderableList].
  final List<ExpandableReorderableListItem<K>> children;

  /// A callback used by the list to report that a list item has been dragged
  /// and dropped to a new location in the list and the application should
  /// update the order of the items.
  ///
  /// The dragged item is available as `onReorderParam.item`.
  ///
  /// The `from` and `to` are the indexes of the items are available with
  /// `onReorderParam.oldIndex` and `onReorderParam.newIndex`.
  ///
  /// The "new" previous and next items (items before and after the drop
  /// position) are available with `onReorderParam.newPreviousItem` and
  /// `onReorderParam.newNextItem` (both nullable).
  /// `onReorderParam.newPreviousItem` will be `null` if the item is dropped at
  /// the beginning of the list while `onReorderParam.newNextItem` will be
  /// `null` if the item is dropped at the end of the list.
  final OnReorder<K>? onReorder;

  /// Scroll Controller.
  final ScrollController? scrollController;

  /// The model controller.
  final ExpandableReorderableListItemModelController<K>? modelsController;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  @override
  _ExpandableReorderableListState<K> createState() =>
      _ExpandableReorderableListState<K>();
}

class _ExpandableReorderableListState<K extends Key>
    extends State<ExpandableReorderableList<K>>
    with TickerProviderStateMixin, OnReorderMixin<K> {
  /// The items tree.
  late ExpandableReorderableListRootItem<K> _itemsTree;
  @override
  ExpandableReorderableListRootItem<K> get itemsTree => _itemsTree;

  /// Link between the widgets and their controllers.
  final animationControllers = <K, AnimationController>{};

  /// Link between the widget and their animations.
  final scaleAnimations = <K, Animation<double>>{};

  /// Map of all the children (from all levels).
  final _itemsMap = <K, ExpandableReorderableListItem<K>>{};
  @override
  Map<K, ExpandableReorderableListItem<K>> get itemsMap => _itemsMap;

  /// Item models of all the children (from all levels).
  late ExpandableReorderableListItemModelController<K> _modelsController;
  @override
  ExpandableReorderableListItemModelController<K> get modelsController =>
      _modelsController;

  /// Key of the item to expand after the build is complete. If `null`, no item
  /// will be expanded.
  K? itemToShow;

  /// The lead widget to insert at the beginning of the items. If not `null`, it
  /// is always visible.
  Widget? lead;

  /// The lead widget to insert at the end of the items. If not `null`, it is
  /// always visible.
  Widget? tail;

  @override
  bool get hasLeads => widget.leads.isNotEmpty;

  @override
  bool get hasTails => widget.tails.isNotEmpty;

  /// Collapse or expand an item.
  ///
  /// {@macro novade.packages.expandable_reorderable_list.collapse_callback}
  Future<void> collapseItemCallback(K key, {bool? isCollapsed}) async {
    final _isCollapsed =
        isCollapsed ?? !_modelsController.items[key]!.isCollapsed;
    final item = itemsMap[key]!;
    if (_isCollapsed && !_modelsController.items[key]!.isCollapsed) {
      final futures = item.children.map(hideItem).fold<List<Future<void>>>(
          <Future<void>>[], (value, element) => [...value, ...element]);
      await Future.wait(futures);

      // We should set `isCollapsed` of the model after the animation.
      //
      // If not, and `isCollapsed` is set before the animations, the animations
      // to hide the items will trigger a scroll and the `buildItem` function.
      // The widget will try to build the list by skipping the collapsed items
      // (since `isCollapsed == true`). However, the `itemCount` still haven't
      // changed because `setState` hasn't been called yet.
      //
      // It will then create errors.
      setState(() {
        _modelsController.items[key]!.isCollapsed = _isCollapsed;
      });
    } else if (!_isCollapsed && _modelsController.items[key]!.isCollapsed) {
      setState(() {
        _modelsController.items[key]!.isCollapsed = _isCollapsed;
        itemToShow = key;
      });
    }
  }

  /// Helper method to give to `onValue` and `onError` of the
  /// [TickerFuture.then].
  ///
  /// We need to do this to resolve the future when a [TickerFuture] is
  /// cancelled.
  /// https://stackoverflow.com/questions/66402424/flutter-widget-test-wait-for-animation
  /// https://stackoverflow.com/a/69931172/12066144
  ///
  /// This is inspired by the implementation of
  /// [TickerFuture.whenCompleteOrCancel] which returns `void` and cannot be
  /// awaited.
  void _thunk(dynamic _) {
    return;
  }

  /// Hide an item. It is used by the [collapseItemCallback].
  List<Future<void>> hideItem(ExpandableReorderableListItem<K> item) {
    final futures = <Future<void>>[];

    // If an item is not collapsed, we need to hide its children too.
    if (!_modelsController.items[item.key]!.isCollapsed) {
      futures.addAll(item.children.map(hideItem).fold<List<Future<void>>>(
          <Future<void>>[], (value, element) => [...value, ...element]));
    }
    final ticker = animationControllers[item.key]!.reverse(); // Hide
    futures.add(ticker.orCancel.then(_thunk,
        onError:
            _thunk)); // Await for the ticker to complete even if it is cancelled.
    return futures;
  }

  /// Show an item. It is used by the [build] if there is an item to show.
  List<Future<void>> showItem(ExpandableReorderableListItem<K> item) {
    final ticker = animationControllers[item.key]!.forward(); // Show
    final futures = <Future<void>>[
      ticker.orCancel.then(_thunk,
          onError:
              _thunk), // Await for the ticker to complete even if it is cancelled.
    ];

    // If an item is not collapsed, we need to show its children too.
    if (!_modelsController.items[item.key]!.isCollapsed) {
      futures.addAll(item.children.map(showItem).fold<List<Future<void>>>(
          <Future<void>>[], (value, element) => [...value, ...element]));
    }
    return futures;
  }

  /// Initialize the controllers for all the children.
  void initItems() {
    animationControllers.clear();
    scaleAnimations.clear();
    itemsMap.clear();
    initLeadTail();
    for (final child in widget.children) {
      initItem(
        item: child,
      );
    }
    clearItemModels();
  }

  /// Initializes the controllers for a unique item. It is used by the [initItems].
  void initItem({
    /// The item.
    required ExpandableReorderableListItem<K> item,
    AnimationController? controller,
    Animation<double>? scaleAnimation,
  }) {
    // Keep the reference in the `itemsMap`
    itemsMap[item.key] = item;

    // Animation Controllers
    controller ??= AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..value = 1;
    scaleAnimation ??= CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    animationControllers[item.key] = controller;
    scaleAnimations[item.key] = scaleAnimation;

    // All the direct children share the same animation controller to be expanded/collapsed at the same time
    final childrenController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..value = 1;
    final childrenScaleAnimation = CurvedAnimation(
      parent: childrenController,
      curve: Curves.fastOutSlowIn,
    );

    // Item model
    if (!_modelsController.items.containsKey(item.key)) {
      final itemModel = ExpandableReorderableListItemModel(
        collapseCallback: ({isCollapsed}) => collapseItemCallback(item.key,
            isCollapsed:
                isCollapsed), // Give the collapse/expand function to the child
      );
      _modelsController.items[item.key] = itemModel;
    }

    for (final child in item.children) {
      initItem(
        item: child,
        controller: childrenController,
        scaleAnimation: childrenScaleAnimation,
      );
    }
  }

  /// Clear the orphan keys of the `itemMap`.
  ///
  /// It can happen when some widgets are removed.
  void clearMap(Map<K, dynamic> map) {
    final keysToRemove = <K>{};
    map.forEach((key, value) {
      if (!itemsMap.containsKey(key)) {
        keysToRemove.add(key);
      }
    });
    keysToRemove.forEach(map.remove);
  }

  /// Clear keys of `itemModelMap`.
  ///
  /// It can happen when some widgets are removed.
  void clearItemModels() {
    clearMap(_modelsController.items);
  }

  /// Build the items.
  ///
  /// It is called by the [build] function.
  void buildItems(BuildContext context) {
    _itemsTree = ExpandableReorderableListRootItem(
      children: widget.children,
    );
  }

  /// Creates [lead] and [tail].
  void initLeadTail() {
    lead = null;
    if (widget.leads.isNotEmpty) {
      lead = _ExpandableReorderableListLeadTail(
        key: const ObjectKey(_LeadTail.lead),
        children: widget.leads,
        axis: widget.scrollDirection,
      );
    }
    tail = null;
    if (widget.tails.isNotEmpty) {
      tail = _ExpandableReorderableListLeadTail(
        key: const ObjectKey(_LeadTail.tail),
        children: widget.tails,
        axis: widget.scrollDirection,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _modelsController = widget.modelsController ??
        ExpandableReorderableListItemModelController<K>();
    initItems();
  }

  @override
  void didUpdateWidget(ExpandableReorderableList<K> oldWidget) {
    super.didUpdateWidget(oldWidget);
    initItems();
  }

  /// Number of visible items in the entire tree.
  int get itemCount {
    var count = _itemsTree.visibleItemCount(_modelsController);
    if (hasLeads) count++;
    if (hasTails) count++;
    return count;
  }

  /// Builder given to the list builders.
  Widget itemBuilder(BuildContext context, int index) {
    var shiftedIndex = index;
    if (hasLeads) {
      if (index == 0) return lead!;
      shiftedIndex--;
    }
    if (index == itemCount - 1 && hasTails) return tail!;

    final item = _itemsTree.itemFromIndex(
      index: shiftedIndex,
      modelsController: _modelsController,
    )!;
    final modelController = _modelsController.items[item.key]!..index = index;
    return SizeTransition(
      key: item.key,
      sizeFactor: scaleAnimations[item.key]!,
      child: item.builder(context, item.child, modelController),
      axis: widget.scrollDirection,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the items before giving it to the list
    buildItems(context);
    if (itemToShow != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showItem(itemsMap[itemToShow]!);
        itemToShow = null;
      });
    }
    return widget.onReorder != null
        ? ReorderableListView.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            onReorder: (oldIndex, newIndex) {
              widget.onReorder!(onReorder(oldIndex, newIndex));
            },
            scrollController: widget.scrollController,
            buildDefaultDragHandles: false,
            scrollDirection: widget.scrollDirection,
          )
        : ListView.builder(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            controller: widget.scrollController,
            scrollDirection: widget.scrollDirection,
          );
  }
}

/// Wrapper for the leads and tails of the [ExpandableReorderableList].
class _ExpandableReorderableListLeadTail extends StatelessWidget {
  /// Wrapper for the leads and tails of the [ExpandableReorderableList].
  const _ExpandableReorderableListLeadTail({
    required Key key,
    this.children = const <Widget>[],
    required this.axis,
  }) : super(key: key);

  /// The children.
  final List<Widget> children;

  /// The axis the leads or tails should be laid out.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) {
      return Column(
        children: children,
      );
    } else {
      return Row(
        children: children,
      );
    }
  }
}
