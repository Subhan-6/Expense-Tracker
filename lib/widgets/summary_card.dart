import 'package:flutter/material.dart';

import '../core/formatters.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total spent', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              Fmt.money(total),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('$count ${count == 1 ? 'expense' : 'expenses'}'),
          ],
        ),
      ),
    );
  }
}
