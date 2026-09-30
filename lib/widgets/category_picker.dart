import 'package:flutter/material.dart';

import '../models/category.dart';

/// A form field that lets the user pick one category with chips.
class CategoryPicker extends FormField<int> {
  CategoryPicker({
    super.key,
    required List<ExpenseCategory> categories,
    super.initialValue,
    super.onSaved,
  }) : super(
          validator: (v) => v == null ? 'Select a category' : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 18, color: c.color),
                      label: Text(c.name),
                      selected: state.value == c.id,
                      onSelected: (_) => state.didChange(c.id),
                    ),
                ],
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(state.context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
}
