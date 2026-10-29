import 'package:flutter/material.dart';

/// Generic "enter an amount" dialog (used for budget and income).
Future<void> showAmountDialog(
  BuildContext context, {
  required String title,
  required Future<void> Function(double amount) onSave,
  double? current,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AmountDialog(title: title, current: current, onSave: onSave),
  );
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.onSave,
    this.current,
  });

  final String title;
  final double? current;
  final Future<void> Function(double amount) onSave;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
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
    await widget.onSave(amount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
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
