import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _delete(BuildContext context, int id, String name) async {
    final categories = context.read<CategoryProvider>();
    final expenses = context.read<ExpenseProvider>();
    final ok = await confirmAction(
      context,
      title: 'Delete "$name"?',
      message: 'All expenses in this category will be deleted too.',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    await categories.delete(id);
    await expenses.load(); // refresh totals after cascade delete
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CategoryProvider>().items;
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.category,
        message: 'No categories yet. Add one!',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = items[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: c.color.withOpacity(0.15),
            child: Icon(c.icon, color: c.color),
          ),
          title: Text(c.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => showCategoryFormDialog(context, category: c),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, c.id!, c.name),
              ),
            ],
          ),
        );
      },
    );
  }
}
