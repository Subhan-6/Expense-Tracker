import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'data/app_database.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'screens/home_screen.dart';

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
          create: (_) =>
              ExpenseProvider(ExpenseRepository(db), BudgetRepository(db))
                ..load(),
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
