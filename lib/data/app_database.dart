import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database once and creates the schema.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_index INTEGER NOT NULL,
        color_index INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        category_id INTEGER NOT NULL
          REFERENCES categories(id) ON DELETE CASCADE
      )''');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('''
      CREATE TABLE budgets (
        month TEXT PRIMARY KEY,
        amount REAL NOT NULL
      )''');

    const defaults = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health'];
    final batch = db.batch();
    for (var i = 0; i < defaults.length; i++) {
      batch.insert('categories', {
        'name': defaults[i],
        'icon_index': i,
        'color_index': i,
      });
    }
    await batch.commit(noResult: true);
  }
}
