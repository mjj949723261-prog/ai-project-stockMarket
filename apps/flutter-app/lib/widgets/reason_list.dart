import 'package:flutter/material.dart';

class ReasonList extends StatelessWidget {
  const ReasonList({super.key, required this.title, required this.reasons});

  final String title;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final reason in reasons) Text('• $reason'),
          ],
        ),
      ),
    );
  }
}

