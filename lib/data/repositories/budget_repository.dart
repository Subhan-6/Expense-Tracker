import 'package:sqflite/sqflite.dart';

import '../../core/formatters.dart';
import '../app_database.dart';

class BudgetRepository {
  BudgetRepository(this._db);
  final AppDatabase _db;

  /// Returns the budget for [month], or the most recent earlier one
  /// (so a budget carries over until you change it).
  Future<double?> getFor(DateTime month) async {
    final db = await _db.database;
    final rows = await db.query(
      'budgets',
      where: 'month <= ?',
      whereArgs: [Fmt.monthKey(month)],
      orderBy: 'month DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['amount'] as num).toDouble();
  }

  Future<void> setFor(DateTime month, double amount) async {
    final db = await _db.database;
    await db.insert(
      'budgets',
      {'month': Fmt.monthKey(month), 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
