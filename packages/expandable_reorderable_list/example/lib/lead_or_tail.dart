import 'package:flutter/material.dart';

class LeadOrTail extends StatelessWidget {
  const LeadOrTail({
    required this.text,
    Key? key,
  }) : super(key: key);

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
