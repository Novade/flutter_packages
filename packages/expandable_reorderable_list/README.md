## Expandable Reorderable List

A wrapper around
[`ReorderableListView`](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)
that allows you to:
- Display a tree of items.
- Expand and collapse them.
- Reorder them.

Checkout [our example](https://github.com/Novade/flutter_packages/tree/master/packages/expandable_reorderable_list/example):


![](https://github.com/Novade/flutter_packages/blob/master/packages/expandable_reorderable_list/resources/expandable_reorderable_list.example.gif)


## Example

This example, inspired by the [`ReorderableListView`](https://api.flutter.dev/flutter/material/ReorderableListView-class.html) documentation,
creates a list using `ExpandableReorderableList`:

```dart
class MyList extends StatefulWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  _MyListState createState() => _MyListState();
}

class _MyListState extends State<HomeTest> {
  final List<int> _items = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final oddItemColor = colorScheme.primary.withOpacity(0.05);
    final evenItemColor = colorScheme.primary.withOpacity(0.15);
    return ExpandableReorderableList<ValueKey<int>>(
      onReorder: (onReorderParam) {
        setState(() {
          var newIndex = onReorderParam.newIndex;
          if (onReorderParam.oldIndex < onReorderParam.newIndex) {
            newIndex -= 1;
          }
          final int item = _items.removeAt(onReorderParam.oldIndex);
          _items.insert(newIndex, item);
        });
      },
      children: _items.map((int item) {
        return ExpandableReorderableListItem<ValueKey<int>>(
          key: ValueKey<int>(item),
          builder: (_, child, model) {
            return ReorderableDragStartListener(
              index: model.index!,
              child: ListTile(
                title: Text('Item $item'),
                tileColor: item.isOdd ? oddItemColor : evenItemColor,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
```

![](https://github.com/Novade/flutter_packages/blob/master/packages/expandable_reorderable_list/resources/expandable_reorderable_list.small_example.gif)



