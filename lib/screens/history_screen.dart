import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/month_selector.dart';
import 'add_edit_expense_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  /// Flattens expenses into [DateTime] headers followed by [Expense] rows.
  List<Object> _groupByDay(List<Expense> expenses) {
    final items = <Object>[];
    DateTime? lastDay;
    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      if (day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(e);
    }
    return items;
  }

  void _delete(BuildContext context, Expense e) {
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    provider.delete(e.id!);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Deleted "${e.title}"'),
        action: SnackBarAction(label: 'Undo', onPressed: () => provider.restore(e)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final items = _groupByDay(provider.expenses);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: MonthSelector(),
        ),
        const CategoryFilterBar(),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long,
                  message: 'No expenses found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    if (item is DateTime) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          Fmt.date(item),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      );
                    }
                    final e = item as Expense;
                    return Dismissible(
                      key: ValueKey('expense-${e.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (_) => _delete(context, e),
                      child: ExpenseTile(
                        expense: e,
                        category: categories.byId(e.categoryId),
                        onTap: () =>
                            AddEditExpenseScreen.open(context, expense: e),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
