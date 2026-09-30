import 'package:flutter/foundation.dart';

import '../data/repositories/category_repository.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repo);
  final CategoryRepository _repo;

  List<ExpenseCategory> _items = const [];
  List<ExpenseCategory> get items => _items;

  ExpenseCategory? byId(int id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> load() async {
    _items = await _repo.getAll();
    notifyListeners();
  }

  bool _nameTaken(String name, {int? exceptId}) => _items.any(
        (c) => c.id != exceptId && c.name.toLowerCase() == name.toLowerCase(),
      );

  /// Returns false when the name already exists.
  Future<bool> add(String name, int iconIndex, int colorIndex) async {
    final clean = name.trim();
    if (_nameTaken(clean)) return false;
    await _repo.insert(ExpenseCategory(
      name: clean,
      iconIndex: iconIndex,
      colorIndex: colorIndex,
    ));
    await load();
    return true;
  }

  Future<bool> update(ExpenseCategory category) async {
    if (_nameTaken(category.name, exceptId: category.id)) return false;
    await _repo.update(category);
    await load();
    return true;
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }
}
