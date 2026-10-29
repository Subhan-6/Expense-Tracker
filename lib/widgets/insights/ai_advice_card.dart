import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../insights/spending_report.dart';
import '../../providers/advisor_provider.dart';
import '../api_key_dialog.dart';

class AiAdviceCard extends StatelessWidget {
  const AiAdviceCard({super.key, required this.report});

  final SpendingReport report;

  @override
  Widget build(BuildContext context) {
    final advisor = context.watch<AdvisorProvider>();
    final scheme = Theme.of(context).colorScheme;
    final advice = advisor.adviceFor(report.month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI savings coach',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (advisor.hasKey)
                  IconButton(
                    icon: const Icon(Icons.key),
                    tooltip: 'API key',
                    onPressed: () => showApiKeyDialog(context),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Claude reviews your category totals and suggests ways to save. '
              'Individual expense titles and notes are never sent.',
            ),
            const SizedBox(height: 12),
            if (!advisor.hasKey)
              FilledButton.icon(
                onPressed: () => showApiKeyDialog(context),
                icon: const Icon(Icons.key),
                label: const Text('Add API key to enable'),
              )
            else
              FilledButton.icon(
                onPressed: (advisor.loading || report.total == 0)
                    ? null
                    : () => advisor.requestAdvice(report),
                icon: advisor.loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(advisor.loading
                    ? 'Analysing...'
                    : (advice == null ? 'Get AI advice' : 'Refresh advice')),
              ),
            if (advisor.hasKey && report.total == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Add some expenses first.'),
              ),
            if (advisor.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(advisor.error!,
                    style: TextStyle(color: scheme.error)),
              ),
            if (advice != null && !advisor.loading) ...[
              const Divider(height: 28),
              Text('Advice for ${Fmt.month(report.month)}',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SelectableText(advice),
            ],
          ],
        ),
      ),
    );
  }
}
