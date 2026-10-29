import 'package:sqflite/sqflite.dart';

import '../../core/formatters.dart';
import '../app_database.dart';

/// Shared logic for "one amount per month" tables (budgets, incomes).
/// The value carries over to later months until it is changed.
class MonthlyAmountRepository {
  MonthlyAmountRepository(this._db, this._table);

  final AppDatabase _db;
  final String _table; // constant table names only, never user input

  Future<double?> getFor(DateTime month) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
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
      _table,
      {'month': Fmt.monthKey(month), 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
