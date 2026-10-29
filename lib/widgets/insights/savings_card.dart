import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../insights/spending_report.dart';
import '../income_dialog.dart';

class SavingsCard extends StatelessWidget {
  const SavingsCard({super.key, required this.report});

  final SpendingReport report;

  @override
  Widget build(BuildContext context) {
    final income = report.income;
    if (income == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Add your monthly income'),
          subtitle: const Text('Needed to calculate your savings and savings rate'),
          trailing: TextButton(
            onPressed: () => showIncomeDialog(context),
            child: const Text('Set'),
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final savings = report.savings ?? 0;
    final rate = report.savingsRate ?? 0;
    final color = savings >= 0 ? Colors.green.shade700 : scheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Savings',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit income',
                  onPressed: () => showIncomeDialog(context, current: income),
                ),
              ],
            ),
            Text(
              Fmt.money(savings),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(report.isCurrentMonth
                ? 'saved so far this month'
                : 'saved this month'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (rate / 20).clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: rate >= 20
                  ? Colors.green.shade600
                  : (rate >= 10 ? Colors.orange : scheme.error),
            ),
            const SizedBox(height: 6),
            Text(
              '${report.isCurrentMonth ? 'Projected savings rate' : 'Savings rate'}: '
              '${rate.toStringAsFixed(0)}%  (target 20%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            _InfoRow('Income', Fmt.money(income)),
            _InfoRow('Spent', Fmt.money(report.total)),
            if (report.isCurrentMonth && report.projectedSavings != null)
              _InfoRow('Projected savings by month end',
                  Fmt.money(report.projectedSavings!)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
