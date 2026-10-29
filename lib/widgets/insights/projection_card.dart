import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../insights/spending_report.dart';

class ProjectionCard extends StatelessWidget {
  const ProjectionCard({super.key, required this.report});

  final SpendingReport report;

  @override
  Widget build(BuildContext context) {
    final pct = report.changePct;
    final changeText = pct == null
        ? '—'
        : '${pct >= 0 ? '+' : '-'}${pct.abs().round()}%';
    final changeColor = pct == null
        ? null
        : (pct > 0 ? Colors.red.shade700 : Colors.green.shade700);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending pace',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Stat('Daily average', Fmt.money(report.dailyAverage)),
                ),
                Expanded(
                  child: _Stat(
                    report.isCurrentMonth ? 'Projected month total' : 'Month total',
                    Fmt.money(report.projectedTotal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Stat(
                    report.isCurrentMonth ? 'Vs same days last month' : 'Vs last month',
                    changeText,
                    color: changeColor,
                  ),
                ),
                Expanded(
                  child: report.isCurrentMonth
                      ? _Stat('Days left', '${report.daysLeft}')
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
