import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_picker.dart';
import '../widgets/confirm_dialog.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expense});

  /// null = add mode, non-null = edit mode.
  final Expense? expense;

  static Future<void> open(BuildContext context, {Expense? expense}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditExpenseScreen(expense: expense)),
    );
  }

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _date;
  int? _categoryId;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(
        text: e == null ? '' : e.amount.toStringAsFixed(0));
    _note = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
    _categoryId = e?.categoryId;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final expense = Expense(
      id: widget.expense?.id,
      title: _title.text.trim(),
      amount: double.parse(_amount.text.replaceAll(',', '')),
      date: _date,
      categoryId: _categoryId!,
      note: _note.text.trim(),
    );
    final provider = context.read<ExpenseProvider>();
    _isEdit ? await provider.update(expense) : await provider.add(expense);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final provider = context.read<ExpenseProvider>();
    final ok = await confirmAction(
      context,
      title: 'Delete expense?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    await provider.delete(widget.expense!.id!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().items;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (_isEdit)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: 'Rs '),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', ''));
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Category', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              const Text('Create a category first (Categories tab).')
            else
              CategoryPicker(
                categories: categories,
                initialValue: _categoryId,
                onSaved: (v) => _categoryId = v,
              ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(Fmt.date(_date)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: categories.isEmpty ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEdit ? 'Save changes' : 'Add expense'),
            ),
          ],
        ),
      ),
    );
  }
}
