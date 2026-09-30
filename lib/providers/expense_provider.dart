import 'package:flutter/foundation.dart';

import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../models/expense.dart';

/// Holds the selected month, its expenses and its budget.
class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._expenseRepo, this._budgetRepo);
  final ExpenseRepository _expenseRepo;
  final BudgetRepository _budgetRepo;

  DateTime _month = _monthOf(DateTime.now());
  List<Expense> _monthExpenses = const [];
  double? _budget;
  int? _filterCategoryId;
  bool _loading = true;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  // ---- state ----
  DateTime get month => _month;
  bool get loading => _loading;
  double? get budget => _budget;
  int? get filterCategoryId => _filterCategoryId;
  bool get canGoNext => _month.isBefore(_monthOf(DateTime.now()));

  /// All expenses in the selected month.
  List<Expense> get monthExpenses => _monthExpenses;

  /// Expenses after applying the category filter (used by History).
  List<Expense> get expenses => _filterCategoryId == null
      ? _monthExpenses
      : _monthExpenses.where((e) => e.categoryId == _filterCategoryId).toList();

  // ---- summaries ----
  double get totalSpent => _monthExpenses.fold(0, (sum, e) => sum + e.amount);

  double? get remaining => _budget == null ? null : _budget! - totalSpent;

  double get budgetProgress =>
      (_budget == null || _budget == 0) ? 0 : totalSpent / _budget!;

  Map<int, double> get totalsByCategory {
    final map = <int, double>{};
    for (final e in _monthExpenses) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  // ---- actions ----
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _monthExpenses = await _expenseRepo.getByMonth(_month);
    _budget = await _budgetRepo.getFor(_month);
    _loading = false;
    notifyListeners();
  }

  Future<void> changeMonth(int delta) {
    _month = DateTime(_month.year, _month.month + delta);
    _filterCategoryId = null;
    return load();
  }

  void setFilter(int? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    await _expenseRepo.insert(e);
    _month = _monthOf(e.date); // jump to the month of the new expense
    await load();
  }

  Future<void> update(Expense e) async {
    await _expenseRepo.update(e);
    _month = _monthOf(e.date);
    await load();
  }

  Future<void> delete(int id) async {
    await _expenseRepo.delete(id);
    await load();
  }

  /// Used by the "Undo" action after deleting.
  Future<void> restore(Expense e) => add(e);

  Future<void> setBudget(double amount) async {
    await _budgetRepo.setFor(_month, amount);
    _budget = amount;
    notifyListeners();
  }
}
