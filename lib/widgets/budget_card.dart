import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../providers/expense_provider.dart';
import 'budget_dialog.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final scheme = Theme.of(context).colorScheme;
    final budget = p.budget;

    if (budget == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.savings_outlined),
          title: const Text('No budget set'),
          subtitle: const Text('Set a monthly budget to track your spending'),
          trailing: TextButton(
            onPressed: () => showBudgetDialog(context),
            child: const Text('Set'),
          ),
        ),
      );
    }

    final over = p.totalSpent > budget;
    final barColor = over
        ? scheme.error
        : (p.budgetProgress > 0.8 ? Colors.orange : scheme.primary);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Monthly budget',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showBudgetDialog(context, current: budget),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: p.budgetProgress.clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: barColor,
            ),
            const SizedBox(height: 8),
            Text('${Fmt.money(p.totalSpent)} of ${Fmt.money(budget)}'),
            Text(
              over
                  ? 'Over budget by ${Fmt.money(p.totalSpent - budget)}'
                  : '${Fmt.money(p.remaining!)} left',
              style: TextStyle(
                color: over ? scheme.error : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
