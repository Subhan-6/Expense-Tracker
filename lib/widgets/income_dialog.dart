import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import 'amount_dialog.dart';

Future<void> showIncomeDialog(BuildContext context, {double? current}) {
  final provider = context.read<ExpenseProvider>();
  return showAmountDialog(
    context,
    title: 'Monthly income',
    current: current,
    onSave: provider.setIncome,
  );
}
