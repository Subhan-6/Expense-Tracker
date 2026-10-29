import '../app_database.dart';
import 'monthly_amount_repository.dart';

class BudgetRepository extends MonthlyAmountRepository {
  BudgetRepository(AppDatabase db) : super(db, 'budgets');
}
