import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import 'amount_dialog.dart';

Future<void> showBudgetDialog(BuildContext context, {double? current}) {
  final provider = context.read<ExpenseProvider>();
  return showAmountDialog(
    context,
    title: 'Monthly budget',
    current: current,
    onSave: provider.setBudget,
  );
}
