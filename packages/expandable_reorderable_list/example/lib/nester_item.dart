import 'dart:math';

import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/material.dart';

class NestedItem {
  NestedItem({
    required this.name,
    required this.level,
    List<NestedItem>? children,
  }) : children = children ?? [];

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

  factory NestedItem._generate({
    required int depth,
    required int width,
    required List<int> position,
  }) {
    final children = depth <= position.length
        ? <NestedItem>[]
        : List<NestedItem>.generate(
            width,
            (index) => NestedItem._generate(
              depth: depth,
              width: width,
              position: position + [index],
            ),
          );

    return NestedItem(
      name: 'Item ${position.join("-")}',
      level: position.length,
      children: children,
    );
  }

  final String name;

  final int level;

  final List<NestedItem> children;

  ExpandableReorderableListItem get item {
    return ExpandableReorderableListItem(
      key: Key(name),
      children: children.map((child) => child.item).toList(),
      builder: (_, __, itemModel) => ItemWidget(
        name: name,
        level: level,
        itemModel: itemModel,
        hasChildren: children.isNotEmpty,
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget(
      {required this.name,
      required this.level,
      required this.itemModel,
      required this.hasChildren,
      Key? key})
      : super(key: key);

  final String name;
  final int level;
  final ExpandableReorderableListItemModel itemModel;
  final bool hasChildren;

  Color get color {
    return Color(
      0xffffffff - ((exp((-level + 1)) * 0x80).toInt() * 0x00010101),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: itemModel.index!,
      child: Theme(
        data: Theme.of(context).copyWith(
          shadowColor: const Color(0xff000000),
        ),
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  SizedBox(width: level * 8),
                  Text(
                    name,
                    style: TextStyle(
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
    );
  }
}
