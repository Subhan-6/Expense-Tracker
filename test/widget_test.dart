import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/insights/insight_engine.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  const engine = InsightEngine();
  final month = DateTime(2026, 9);

  Expense e(int category, double amount, int day) => Expense(
        title: 'test',
        amount: amount,
        date: DateTime(2026, 9, day),
        categoryId: category,
      );

  test('finds the top category and calculates savings', () {
    final report = engine.analyze(
      month: month,
      expenses: [e(1, 6000, 3), e(2, 2000, 5)],
      previousExpenses: const [],
      categoryNames: {1: 'Food', 2: 'Transport'},
      income: 20000,
      now: DateTime(2026, 10, 15),
    );
    expect(report.total, 8000);
    expect(report.categories.first.name, 'Food');
    expect(report.categories.first.share, closeTo(0.75, 0.001));
    expect(report.savings, 12000);
    expect(report.savingsRate, closeTo(60, 0.001));
  });

  test('compares a category with last month', () {
    final report = engine.analyze(
      month: month,
      expenses: [e(1, 6000, 3)],
      previousExpenses: [
        Expense(
          title: 'old',
          amount: 3000,
          date: DateTime(2026, 8, 2),
          categoryId: 1,
        ),
      ],
      categoryNames: {1: 'Food'},
      now: DateTime(2026, 10, 15),
    );
    expect(report.categories.first.changePct, closeTo(100, 0.001));
  });

  test('projects month-end spending for the running month', () {
    final report = engine.analyze(
      month: month,
      expenses: [e(1, 5000, 4)],
      previousExpenses: const [],
      categoryNames: {1: 'Food'},
      now: DateTime(2026, 9, 10),
    );
    expect(report.isCurrentMonth, true);
    expect(report.dailyAverage, 500);
    expect(report.projectedTotal, 15000);
  });
}