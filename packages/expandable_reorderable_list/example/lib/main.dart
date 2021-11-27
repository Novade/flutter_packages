import 'package:example/lead_or_tail.dart';
import 'package:example/nester_item.dart';
import 'package:expandable_reorderable_list/expandable_reorderable_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Expandable reorderable list'),
        ),
        body: Builder(builder: (context) {
          print('sh ${Theme.of(context).shadowColor}');
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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final items = NestedItem.generate(depth: 3, width: 4);

  void onReorder(OnReorderParam<Key> onReorderParam) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpandableReorderableList<Key>(
        leads: const [
          LeadOrTail(text: 'Header'),
        ],
        tails: const [
          LeadOrTail(text: 'Tail'),
        ],
        onReorder: onReorder,
        children: items.item.children,
      ),
    );
  }
}
