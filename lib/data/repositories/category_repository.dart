import '../../models/category.dart';
import '../app_database.dart';

class CategoryRepository {
  CategoryRepository(this._db);
  final AppDatabase _db;

  Future<List<ExpenseCategory>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map(ExpenseCategory.fromMap).toList();
  }

  Future<void> insert(ExpenseCategory c) async {
    final db = await _db.database;
    await db.insert('categories', c.toMap());
  }

  Future<void> update(ExpenseCategory c) async {
    final db = await _db.database;
    await db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  /// Also removes the category's expenses (ON DELETE CASCADE).
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
