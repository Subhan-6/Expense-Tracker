import 'package:flutter/material.dart';

import '../core/category_options.dart';

class ExpenseCategory {
  const ExpenseCategory({
    this.id,
    required this.name,
    required this.iconIndex,
    required this.colorIndex,
  });

  final int? id;
  final String name;
  final int iconIndex;
  final int colorIndex;

  IconData get icon => kCategoryIcons[iconIndex % kCategoryIcons.length];
  Color get color => kCategoryColors[colorIndex % kCategoryColors.length];

  ExpenseCategory copyWith({String? name, int? iconIndex, int? colorIndex}) =>
      ExpenseCategory(
        id: id,
        name: name ?? this.name,
        iconIndex: iconIndex ?? this.iconIndex,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'icon_index': iconIndex,
        'color_index': colorIndex,
      };

  factory ExpenseCategory.fromMap(Map<String, Object?> m) => ExpenseCategory(
        id: m['id'] as int,
        name: m['name'] as String,
        iconIndex: m['icon_index'] as int,
        colorIndex: m['color_index'] as int,
      );
}
