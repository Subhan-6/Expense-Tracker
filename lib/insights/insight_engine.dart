import '../core/formatters.dart';
import '../models/expense.dart';
import 'spending_report.dart';

/// Pure, deterministic analysis of a month of expenses.
/// All numbers come from here (not from an AI model), so they are exact.
class InsightEngine {
  const InsightEngine();

  /// Commonly used savings target (20% of income).
  static const double _savingsTarget = 0.20;

  SpendingReport analyze({
    required DateTime month,
    required List<Expense> expenses,
    required List<Expense> previousExpenses,
    required Map<int, String> categoryNames,
    double? budget,
    double? income,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final isCurrent = month.year == today.year && month.month == today.month;
    final daysElapsed = isCurrent ? today.day : daysInMonth;
    final daysLeft = isCurrent ? daysInMonth - today.day : 0;

    // Compare like with like: only the same days of the previous month.
    final prevComparable =
        previousExpenses.where((e) => e.date.day <= daysElapsed).toList();

    final total = _sum(expenses);
    final previousTotal = _sum(prevComparable);
    final current = _byCategory(expenses);
    final previous = _byCategory(prevComparable);

    final categories = [
      for (final e in current.entries)
        CategorySpend(
          categoryId: e.key,
          name: categoryNames[e.key] ?? 'Unknown',
          amount: e.value,
          share: total == 0 ? 0.0 : e.value / total,
          previousAmount: previous[e.key] ?? 0.0,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    Expense? biggest;
    for (final e in expenses) {
      if (biggest == null || e.amount > biggest.amount) biggest = e;
    }

    final dailyAverage = daysElapsed == 0 ? 0.0 : total / daysElapsed;
    final projected = isCurrent ? dailyAverage * daysInMonth : total;

    return SpendingReport(
      month: month,
      total: total,
      previousTotal: previousTotal,
      categories: categories,
      dailyAverage: dailyAverage,
      projectedTotal: projected,
      daysLeft: daysLeft,
      isCurrentMonth: isCurrent,
      biggestExpense: biggest,
      budget: budget,
      income: income,
      tips: _buildTips(
        total: total,
        categories: categories,
        dailyAverage: dailyAverage,
        projected: projected,
        daysLeft: daysLeft,
        isCurrent: isCurrent,
        budget: budget,
        income: income,
      ),
    );
  }

  // ---------------------------------------------------------------- tips

  List<Tip> _buildTips({
    required double total,
    required List<CategorySpend> categories,
    required double dailyAverage,
    required double projected,
    required int daysLeft,
    required bool isCurrent,
    double? budget,
    double? income,
  }) {
    if (total == 0 || categories.isEmpty) {
      return const [
        Tip(TipLevel.info, 'No spending recorded',
            'Add some expenses to see insights for this month.'),
      ];
    }

    final tips = <Tip>[];

    // 1. Biggest category
    final top = categories.first;
    final heavy = top.share >= 0.4;
    tips.add(Tip(
      heavy ? TipLevel.warning : TipLevel.info,
      '${top.name} is your biggest expense',
      '${Fmt.money(top.amount)} (${(top.share * 100).round()}% of spending).'
      '${heavy ? ' One category takes a large share, so it is the best place to look for savings.' : ''}',
    ));

    // 2. Category rising fastest (by rupee increase)
    CategorySpend? rising;
    for (final c in categories) {
      final pct = c.changePct;
      if (pct == null || pct < 25) continue;
      final delta = c.amount - c.previousAmount;
      if (delta <= 0) continue;
      if (rising == null || delta > rising.amount - rising.previousAmount) {
        rising = c;
      }
    }
    if (rising != null) {
      tips.add(Tip(
        TipLevel.warning,
        '${rising.name} is up ${rising.changePct!.round()}%',
        'You spent ${Fmt.money(rising.amount - rising.previousAmount)} more than in the same period last month.',
      ));
    }

    // 3. Best improvement
    CategorySpend? falling;
    for (final c in categories) {
      final pct = c.changePct;
      if (pct == null || pct > -20) continue;
      final delta = c.previousAmount - c.amount;
      if (falling == null || delta > falling.previousAmount - falling.amount) {
        falling = c;
      }
    }
    if (falling != null) {
      tips.add(Tip(
        TipLevel.good,
        'Nice work on ${falling.name}',
        'Down ${(-falling.changePct!).round()}% compared with the same period last month, '
            'saving ${Fmt.money(falling.previousAmount - falling.amount)}.',
      ));
    }

    // 4. Budget
    if (budget != null && budget > 0) {
      final over = total - budget;
      final used = (total / budget * 100).round();
      if (over > 0) {
        tips.add(Tip(TipLevel.warning, 'Over budget',
            'You have spent ${Fmt.money(over)} more than your ${Fmt.money(budget)} budget.'));
      } else if (isCurrent && projected > budget) {
        final left = budget - total;
        final perDay = daysLeft > 0 ? left / daysLeft : 0.0;
        tips.add(Tip(
          TipLevel.warning,
          'Heading over budget',
          'At your current pace you will overspend by about ${Fmt.money(projected - budget)}. '
              'Keeping spending under ${Fmt.money(perDay)} per day for the remaining $daysLeft days keeps you within budget.',
        ));
      } else if (used >= 80) {
        tips.add(Tip(TipLevel.info, 'Close to your budget',
            'You have used $used% of your budget.'));
      } else {
        tips.add(Tip(TipLevel.good, 'On track',
            'You have used $used% of your budget.'));
      }
    }

    // 5. Savings
    if (income != null && income > 0) {
      final basis = isCurrent ? projected : total;
      final saved = income - basis;
      final rate = saved / income * 100;
      final target = income * _savingsTarget;
      final lead = isCurrent ? 'At this pace you will save' : 'You saved';
      if (saved < 0) {
        tips.add(Tip(
          TipLevel.warning,
          'Spending exceeds income',
          isCurrent
              ? 'At this pace you will spend ${Fmt.money(-saved)} more than you earn this month.'
              : 'You spent ${Fmt.money(-saved)} more than you earned this month.',
        ));
      } else if (rate < 10) {
        tips.add(Tip(
          TipLevel.warning,
          'Low savings rate',
          '$lead ${rate.round()}% of your income. A common target is 20% (${Fmt.money(target)}); '
              'cutting about ${Fmt.money(target - saved)} would reach it.',
        ));
      } else if (rate < 20) {
        tips.add(Tip(
          TipLevel.info,
          'Almost at the savings target',
          '$lead ${rate.round()}% of your income. ${Fmt.money(target - saved)} more would reach the common 20% target.',
        ));
      } else {
        tips.add(Tip(
          TipLevel.good,
          'Strong savings',
          '$lead ${rate.round()}% of your income, above the common 20% target.',
        ));
      }
    }

    // 6. Small cut in the biggest category
    final topMonthly = isCurrent ? top.share * projected : top.amount;
    final tenPct = topMonthly * 0.10;
    tips.add(Tip(
      TipLevel.info,
      'A small cut adds up',
      'Trimming ${top.name} by 10% saves about ${Fmt.money(tenPct)} a month '
          '(${Fmt.money(tenPct * 12)} over a year).',
    ));

    // 7. Daily average
    tips.add(Tip(TipLevel.info, 'Daily spending',
        'You spend about ${Fmt.money(dailyAverage)} per day.'));

    return tips;
  }

  // ------------------------------------------------------------- helpers

  double _sum(Iterable<Expense> list) =>
      list.fold<double>(0, (sum, e) => sum + e.amount);

  Map<int, double> _byCategory(Iterable<Expense> list) {
    final map = <int, double>{};
    for (final e in list) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }
}
