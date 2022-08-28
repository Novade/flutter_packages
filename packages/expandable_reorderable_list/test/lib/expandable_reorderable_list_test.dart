import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/utils.dart';

void main() {
  group('Display:', () {
    testWidgets('It should display a reorderable list', (tester) async {
      final widget = ExpandableReorderableList(
        children: [
          ExpandableReorderableListItem(
            child: Container(
              color: Colors.red,
              height: 50,
            ),
            key: const Key('red'),
            children: [
              ExpandableReorderableListItem(
                child: Container(
                  color: Colors.pink,
                  height: 50,
                ),
                key: const Key('pink'),
              ),
              ExpandableReorderableListItem(
                child: Container(
                  color: Colors.purple,
                  height: 50,
                ),
                key: const Key('purple'),
              ),
            ],
          ),
          ExpandableReorderableListItem(
            child: Container(
              color: Colors.orange,
              height: 50,
            ),
            key: const Key('orange'),
            children: [
              ExpandableReorderableListItem(
                child: Container(
                  color: Colors.yellow,
                  height: 50,
                ),
                key: const Key('yellow'),
              ),
            ],
          ),
          ExpandableReorderableListItem(
            child: Container(
              color: Colors.green,
              height: 50,
            ),
            key: const Key('green'),
          ),
        ],
        onReorder: (_) {},
      );
      await tester.initWidgetTree();
      await tester.pumpWidget(MaterialApp(home: widget));

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableListView &&
              widget.header == null &&
              widget.itemCount == 6,
        ),
        findsOneWidget,
      );
      await expectLater(find.byWidget(widget),
          matchesGoldenFile('golden/expandable_reorderable_list_view.png'));
      await tester.clearWidgetTree();
    });

    testWidgets(
      'It should display a reorderable list scrollable in the horizontal direction',
      (tester) async {
        final widget = ExpandableReorderableList(
          scrollDirection: Axis.horizontal,
          children: [
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.red,
                width: 50,
              ),
              key: const Key('red'),
              children: [
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.pink,
                    width: 50,
                  ),
                  key: const Key('pink'),
                ),
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.purple,
                    width: 50,
                  ),
                  key: const Key('purple'),
                ),
              ],
            ),
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.orange,
                width: 50,
              ),
              key: const Key('orange'),
              children: [
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.yellow,
                    width: 50,
                  ),
                  key: const Key('yellow'),
                ),
              ],
            ),
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.green,
                width: 50,
              ),
              key: const Key('green'),
            ),
          ],
          onReorder: (_) {},
        );
        await tester.initWidgetTree();
        await tester.pumpWidget(MaterialApp(home: widget));

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is ReorderableListView &&
                widget.header == null &&
                widget.itemCount == 6,
          ),
          findsOneWidget,
        );
        await expectLater(
            find.byWidget(widget),
            matchesGoldenFile(
                'golden/expandable_reorderable_list_view.horizontal.png'));
        await tester.clearWidgetTree();
      },
    );

    testWidgets('It should display a list view when disabled', (tester) async {
      final widget = MaterialApp(
        home: ExpandableReorderableList(
          children: [
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.red,
                height: 50,
              ),
              key: const Key('red'),
              children: [
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.pink,
                    height: 50,
                  ),
                  key: const Key('pink'),
                ),
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.purple,
                    height: 50,
                  ),
                  key: const Key('purple'),
                ),
              ],
            ),
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.orange,
                height: 50,
              ),
              key: const Key('orange'),
              children: [
                ExpandableReorderableListItem(
                  child: Container(
                    color: Colors.yellow,
                    height: 50,
                  ),
                  key: const Key('yellow'),
                ),
              ],
            ),
            ExpandableReorderableListItem(
              child: Container(
                color: Colors.green,
                height: 50,
              ),
              key: const Key('green'),
            ),
          ],
        ),
      );
      await tester.pumpWidget(widget);
      await tester.initWidgetTree();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ReorderableListView), findsNothing);
      await tester.clearWidgetTree();
    });

    testWidgets('It should display the least with a deeply nested tree',
        (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(250, 500);
      tester.binding.window.devicePixelRatioTestValue = 1;
      final tree = const BuildTreeInput([
        BuildTreeInput(),
        BuildTreeInput([
          BuildTreeInput([
            BuildTreeInput([
              BuildTreeInput(),
            ]),
            BuildTreeInput(),
          ]),
          BuildTreeInput(),
          BuildTreeInput(),
        ]),
        BuildTreeInput([
          BuildTreeInput([
            BuildTreeInput([
              BuildTreeInput(),
            ]),
            BuildTreeInput([
              BuildTreeInput([
                BuildTreeInput(),
                BuildTreeInput(),
              ]),
            ]),
          ]),
          BuildTreeInput(),
          BuildTreeInput(),
        ]),
      ]).toTree();
      final widget = MaterialApp(
        home: SizedBox(
          key: const Key('home'),
          child: ExpandableReorderableList<Key>(
            children: tree.children,
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.initWidgetTree();

      await expectLater(
          find.byKey(const Key('home')),
          matchesGoldenFile(
              'golden/expandable_reorderable_list_view.4_levels.png'));
      await tester.clearWidgetTree();
    });
  });

  group('Collapse and expand', () {
    testWidgets('It should collapse and expand the items', (tester) async {
      final tree = const BuildTreeInput([
        BuildTreeInput([
          BuildTreeInput([
            BuildTreeInput(),
            BuildTreeInput(),
          ]),
          BuildTreeInput(),
        ]),
        BuildTreeInput([
          BuildTreeInput([
            BuildTreeInput(),
          ]),
          BuildTreeInput(),
        ]),
      ]).toTree();
      final modelsController =
          ExpandableReorderableListItemModelController<Key>();
      final widget = MaterialApp(
        home: ExpandableReorderableList<Key>(
          modelsController: modelsController,
          children: tree.children,
        ),
      );

      await tester.pumpWidget(widget);
      await tester.initWidgetTree();

      // All the items should be visible
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );

      // Collapse the item 0

      modelsController.items[const Key('0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // The children of 0 should not be visible.
      expectItems(
        ['0', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );
      expectItems(
        ['0.0', '0.0.0', '0.0.1', '0.1'],
        findsNothing,
      );

      // Expand the item 0

      modelsController.items[const Key('0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // All the items should be visible
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );

      // Collapse the item 0.0

      modelsController.items[const Key('0.0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // The children of 0 should not be visible.
      expectItems(
        ['0', '0.0', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );
      expectItems(
        ['0.0.0', '0.0.1'],
        findsNothing,
      );

      // Expand the item 0.0

      modelsController.items[const Key('0.0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // All the items should be visible
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );

      // Collapse the item 1

      modelsController.items[const Key('1')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // The children of 0 should not be visible.
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1'],
        findsOneWidget,
      );
      expectItems(
        ['1.0', '1.0.0', '1.1'],
        findsNothing,
      );

      // Expand the item 1

      modelsController.items[const Key('1')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // All the items should be visible
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );

      // Collapse the item 1.0

      modelsController.items[const Key('1.0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // The children of 0 should not be visible.
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.1'],
        findsOneWidget,
      );
      expectItems(
        ['1.0.0'],
        findsNothing,
      );

      // Expand the item 1

      modelsController.items[const Key('1.0')]!.collapseCallback!();
      await tester.pumpAndSettle();
      // All the items should be visible
      expectItems(
        ['0', '0.0', '0.0.0', '0.0.1', '0.1', '1', '1.0', '1.0.0', '1.1'],
        findsOneWidget,
      );

      await tester.clearWidgetTree();
    });
  });

  group('onReordered', () {
    testWidgets('It should reorder the items', (tester) async {
      final onReorderCalls = <OnReorderParam>[];

      final tree = const BuildTreeInput([
        BuildTreeInput([
          BuildTreeInput(),
          BuildTreeInput(),
        ]),
        BuildTreeInput([
          BuildTreeInput(),
          BuildTreeInput(),
        ]),
      ]).toTree();
      final widget = MaterialApp(
        home: ExpandableReorderableList<Key>(
          children: tree.children,
          onReorder: onReorderCalls.add,
        ),
      );

      await tester.pumpWidget(widget);
      await tester.initWidgetTree();

      tester.expectOrdered(['0', '0.0', '0.1', '1', '1.0', '1.1']);

      // * Move the first item at the second place.

      // Start drag gesture on the first item.
      var drag = await tester.startGesture(tester.getCenter(find.item('0')));
      await tester.pump(kPressTimeout);

      // Drag enough to move down the first item.
      await drag.moveBy(Offset(0, ItemWidget.heightFromLevel(1) / 2 + 1));
      await tester.pump();
      await drag.up();
      await tester.pump();

      expect(onReorderCalls.length, 1);
      expect(onReorderCalls.last.item.key, const Key('0'));
      expect(onReorderCalls.last.oldIndex, 0);
      expect(onReorderCalls.last.newIndex, 2);
      expect(onReorderCalls.last.newNextItem!.key, const Key('0.1'));
      expect(onReorderCalls.last.newPreviousItem!.key, const Key('0.0'));

      onReorderCalls.clear();

      // * Move the second item at the first place.

      // Start drag gesture on the second item.
      drag = await tester.startGesture(tester.getCenter(find.item('0.0')));
      await tester.pump(kPressTimeout);

      // Drag enough to move up the second item.
      await drag.moveBy(Offset(0, -ItemWidget.heightFromLevel(1)));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(onReorderCalls.length, 1);
      expect(onReorderCalls.last.item.key, const Key('0.0'));
      expect(onReorderCalls.last.oldIndex, 1);
      expect(onReorderCalls.last.newIndex, 0);
      expect(onReorderCalls.last.newNextItem!.key, const Key('0'));
      expect(onReorderCalls.last.newPreviousItem, null);

      onReorderCalls.clear();

      // * Move the second last item at the last place.

      // Start drag gesture on the second last item.
      drag = await tester.startGesture(tester.getCenter(find.item('1.0')));
      await tester.pump(kPressTimeout);

      // Drag enough to move down the second last item.
      await drag.moveBy(Offset(0, 2 * ItemWidget.heightFromLevel(2) + 1));
      await tester.pump();
      await drag.up();
      await tester.pumpAndSettle();

      expect(onReorderCalls.length, 1);
      expect(onReorderCalls.last.item.key, const Key('1.0'));
      expect(onReorderCalls.last.oldIndex, 4);
      expect(onReorderCalls.last.newIndex, 6);
      expect(onReorderCalls.last.newNextItem, null);
      expect(onReorderCalls.last.newPreviousItem!.key, const Key('1.1'));

      onReorderCalls.clear();

      // * Move the last item at the second last place.

      // Start drag gesture on the last item.
      drag = await tester.startGesture(tester.getCenter(find.item('1.1')));
      await tester.pump(kPressTimeout);

      // Drag enough to move up the last item.
      await drag.moveBy(Offset(0, -ItemWidget.heightFromLevel(2)));
      await tester.pump();
      await drag.up();
      await tester.pump();

      expect(onReorderCalls.length, 1);
      expect(onReorderCalls.last.item.key, const Key('1.1'));
      expect(onReorderCalls.last.oldIndex, 5);
      expect(onReorderCalls.last.newIndex, 4);
      expect(onReorderCalls.last.newNextItem!.key, const Key('1.0'));
      expect(onReorderCalls.last.newPreviousItem!.key, const Key('1'));

      onReorderCalls.clear();

      await tester.clearWidgetTree();
    });
  });
}
