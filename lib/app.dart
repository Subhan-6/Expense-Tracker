import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'data/app_database.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/income_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'insights/insight_engine.dart';
import 'insights/spending_report.dart';
import 'providers/advisor_provider.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';
import 'services/ai_advisor_service.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(CategoryRepository(db))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            ExpenseRepository(db),
            BudgetRepository(db),
            IncomeRepository(db),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AdvisorProvider(SettingsRepository(), AiAdvisorService())..init(),
        ),
        // Recomputed whenever expenses or categories change.
        ProxyProvider2<ExpenseProvider, CategoryProvider, SpendingReport>(
          update: (_, expenses, categories, _) =>
              const InsightEngine().analyze(
            month: expenses.month,
            expenses: expenses.monthExpenses,
            previousExpenses: expenses.previousExpenses,
            categoryNames: {
              for (final c in categories.items) c.id!: c.name,
            },
            budget: expenses.budget,
            income: expenses.income,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
