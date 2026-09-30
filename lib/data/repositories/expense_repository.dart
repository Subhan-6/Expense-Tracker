import 'package:sqflite/sqflite.dart';

import '../../models/expense.dart';
import '../app_database.dart';

class ExpenseRepository {
  ExpenseRepository(this._db);
  final AppDatabase _db;

  Future<List<Expense>> getByMonth(DateTime month) async {
    final db = await _db.database;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<void> insert(Expense e) async {
    final db = await _db.database;
    await db.insert('expenses', e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Expense e) async {
    final db = await _db.database;
    await db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
