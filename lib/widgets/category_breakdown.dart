import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

/// Spending per category with a proportional bar.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
    required this.totals,
    required this.categories,
  });

  final Map<int, double> totals;
  final CategoryProvider categories;

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final grandTotal = totals.values.fold<double>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (entries.isEmpty) const Text('Nothing to show yet'),
            for (final entry in entries)
              _BreakdownRow(
                category: categories.byId(entry.key),
                amount: entry.value,
                share: grandTotal == 0 ? 0 : entry.value / grandTotal,
              ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.category,
    required this.amount,
    required this.share,
  });

  final ExpenseCategory? category;
  final double amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(category?.icon ?? Icons.help_outline, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(category?.name ?? 'Unknown')),
              Text(Fmt.money(amount)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: share,
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
