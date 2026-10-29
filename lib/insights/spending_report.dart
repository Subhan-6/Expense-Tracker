import '../core/formatters.dart';
import '../models/expense.dart';

enum TipLevel { good, info, warning }

class Tip {
  const Tip(this.level, this.title, this.message);

  final TipLevel level;
  final String title;
  final String message;
}

class CategorySpend {
  const CategorySpend({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.share,
    required this.previousAmount,
  });

  final int categoryId;
  final String name;
  final double amount;

  /// 0..1 share of the month's total.
  final double share;

  /// Spending in the same period of the previous month.
  final double previousAmount;

  double? get changePct => previousAmount == 0
      ? null
      : (amount - previousAmount) / previousAmount * 100;
}

/// Everything the Insights screen and the AI advisor need for one month.
class SpendingReport {
  const SpendingReport({
    required this.month,
    required this.total,
    required this.previousTotal,
    required this.categories,
    required this.dailyAverage,
    required this.projectedTotal,
    required this.daysLeft,
    required this.isCurrentMonth,
    required this.tips,
    this.biggestExpense,
    this.budget,
    this.income,
  });

  final DateTime month;
  final double total;

  /// Previous month, same number of days (fair comparison).
  final double previousTotal;
  final List<CategorySpend> categories; // sorted, biggest first
  final double dailyAverage;
  final double projectedTotal; // equals total for finished months
  final int daysLeft;
  final bool isCurrentMonth;
  final List<Tip> tips;
  final Expense? biggestExpense;
  final double? budget;
  final double? income;

  double? get changePct =>
      previousTotal == 0 ? null : (total - previousTotal) / previousTotal * 100;

  /// Income minus what has been spent so far.
  double? get savings => income == null ? null : income! - total;

  /// Income minus projected month-end spending.
  double? get projectedSavings =>
      income == null ? null : income! - projectedTotal;

  /// Savings rate in %. For the running month it uses the projected spend,
  /// otherwise the first days of the month would look unrealistically good.
  double? get savingsRate {
    final inc = income;
    if (inc == null || inc <= 0) return null;
    final spend = isCurrentMonth ? projectedTotal : total;
    return (inc - spend) / inc * 100;
  }

  /// Aggregates only. Expense titles and notes are never included.
  Map<String, Object?> toAiPayload() => {
        'month': Fmt.monthKey(month),
        'currency': 'PKR',
        'isCurrentMonth': isCurrentMonth,
        'daysLeftInMonth': daysLeft,
        'totalSpent': total.round(),
        'sameDaysLastMonthSpent': previousTotal.round(),
        'monthlyIncome': income?.round(),
        'monthlyBudget': budget?.round(),
        'savedSoFar': savings?.round(),
        'savingsRatePct': savingsRate?.round(),
        'dailyAverage': dailyAverage.round(),
        'projectedMonthEndSpend': projectedTotal.round(),
        'categories': [
          for (final c in categories)
            {
              'name': c.name,
              'amount': c.amount.round(),
              'sharePct': (c.share * 100).round(),
              'changeVsLastMonthPct': c.changePct?.round(),
            },
        ],
      };
}
