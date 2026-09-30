import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/category_options.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

/// Add mode when [category] is null, edit mode otherwise.
Future<void> showCategoryFormDialog(BuildContext context,
    {ExpenseCategory? category}) {
  return showDialog(
    context: context,
    builder: (_) => _CategoryFormDialog(category: category),
  );
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.category});
  final ExpenseCategory? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.category?.name ?? '');
  late int _iconIndex = widget.category?.iconIndex ?? 0;
  late int _colorIndex = widget.category?.colorIndex ?? 0;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name');
      return;
    }
    final provider = context.read<CategoryProvider>();
    final existing = widget.category;
    final ok = existing == null
        ? await provider.add(name, _iconIndex, _colorIndex)
        : await provider.update(existing.copyWith(
            name: name, iconIndex: _iconIndex, colorIndex: _colorIndex));
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'A category with this name already exists');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = kCategoryColors[_colorIndex];
    return AlertDialog(
      title: Text(widget.category == null ? 'New category' : 'Edit category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration:
                  InputDecoration(labelText: 'Name', errorText: _error),
            ),
            const SizedBox(height: 16),
            const Text('Icon'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < kCategoryIcons.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _iconIndex = i),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: i == _iconIndex
                          ? color.withOpacity(0.25)
                          : Colors.transparent,
                      child: Icon(kCategoryIcons[i],
                          color: i == _iconIndex ? color : Colors.grey),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < kCategoryColors.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: kCategoryColors[i],
                      child: i == _colorIndex
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
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
