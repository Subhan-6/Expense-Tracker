import 'package:flutter/material.dart';

import '../../insights/spending_report.dart';

class TipsCard extends StatelessWidget {
  const TipsCard({super.key, required this.tips});

  final List<Tip> tips;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Insights', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final tip in tips) _TipRow(tip: tip),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});

  final Tip tip;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (tip.level) {
      TipLevel.good => (Icons.check_circle, Colors.green.shade600),
      TipLevel.info => (Icons.lightbulb_outline, Colors.blue.shade600),
      TipLevel.warning => (Icons.warning_amber_rounded, Colors.orange.shade800),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(tip.message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
