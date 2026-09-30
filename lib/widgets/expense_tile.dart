import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/category.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    this.onTap,
  });

  final Expense expense;
  final ExpenseCategory? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Colors.grey;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(category?.icon ?? Icons.help_outline, color: color),
      ),
      title: Text(expense.title),
      subtitle: Text('${category?.name ?? 'Unknown'} • ${Fmt.date(expense.date)}'),
      trailing: Text(
        Fmt.money(expense.amount),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
