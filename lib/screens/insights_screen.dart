import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../insights/spending_report.dart';
import '../widgets/insights/ai_advice_card.dart';
import '../widgets/insights/projection_card.dart';
import '../widgets/insights/savings_card.dart';
import '../widgets/insights/tips_card.dart';
import '../widgets/insights/top_spending_card.dart';
import '../widgets/month_selector.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.watch<SpendingReport>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const MonthSelector(),
        const SizedBox(height: 8),
        SavingsCard(report: report),
        const SizedBox(height: 12),
        TopSpendingCard(report: report),
        const SizedBox(height: 12),
        ProjectionCard(report: report),
        const SizedBox(height: 12),
        TipsCard(tips: report.tips),
        const SizedBox(height: 12),
        AiAdviceCard(report: report),
      ],
    );
  }
}
