import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../insights/spending_report.dart';

class TopSpendingCard extends StatelessWidget {
  const TopSpendingCard({super.key, required this.report});

  final SpendingReport report;

  @override
  Widget build(BuildContext context) {
    final top = report.categories.take(3).toList();
    final biggest = report.biggestExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where your money goes',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (top.isEmpty) const Text('No spending recorded yet'),
            for (var i = 0; i < top.length; i++)
              _TopRow(rank: i + 1, spend: top[i]),
            if (biggest != null) ...[
              const Divider(),
              Text(
                'Biggest single expense: ${biggest.title} (${Fmt.money(biggest.amount)})',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.rank, required this.spend});

  final int rank;
  final CategorySpend spend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = spend.changePct;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: scheme.primaryContainer,
                child: Text('$rank', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(spend.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (pct != null) _ChangeChip(pct: pct),
              const SizedBox(width: 8),
              Text(Fmt.money(spend.amount)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: spend.share,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(spend.share * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

/// Spending going up is shown in red, going down in green.
class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    final up = pct > 0;
    final color = up ? Colors.red.shade700 : Colors.green.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14, color: color),
        Text('${pct.abs().round()}%',
            style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
