import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/expense_tile.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final categories = context.watch<CategoryProvider>();
    final recent = expenses.monthExpenses.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const MonthSelector(),
        const SizedBox(height: 8),
        SummaryCard(
          total: expenses.totalSpent,
          count: expenses.monthExpenses.length,
        ),
        const SizedBox(height: 12),
        const BudgetCard(),
        const SizedBox(height: 12),
        CategoryBreakdown(
          totals: expenses.totalsByCategory,
          categories: categories,
        ),
        const SizedBox(height: 16),
        Text('Recent', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No expenses this month')),
          ),
        for (final e in recent)
          ExpenseTile(
            expense: e,
            category: categories.byId(e.categoryId),
            onTap: () => AddEditExpenseScreen.open(context, expense: e),
          ),
      ],
    );
  }
}
