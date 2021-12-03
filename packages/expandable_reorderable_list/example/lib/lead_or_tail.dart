import 'package:flutter/material.dart';

/// Widget to display the lead or the tail of the list of items.
class LeadOrTail extends StatelessWidget {
  /// Widget to display the lead or the tail of the list of items.
  const LeadOrTail({
    required this.text,
    Key? key,
  }) : super(key: key);

  /// The text of the widget.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          child: Center(child: Text(text)),
        ),
      ),
    );
  }
}
