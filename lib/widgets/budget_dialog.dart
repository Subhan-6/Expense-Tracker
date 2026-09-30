import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

Future<void> showBudgetDialog(BuildContext context, {double? current}) {
  return showDialog(
    context: context,
    builder: (_) => _BudgetDialog(current: current),
  );
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({this.current});
  final double? current;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.current?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_controller.text.replaceAll(',', ''));
    await context.read<ExpenseProvider>().setBudget(amount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monthly budget'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration:
              const InputDecoration(labelText: 'Amount', prefixText: 'Rs '),
          validator: (v) {
            final n = double.tryParse((v ?? '').replaceAll(',', ''));
            return (n == null || n <= 0) ? 'Enter a valid amount' : null;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
