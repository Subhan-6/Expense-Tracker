import '../app_database.dart';
import 'monthly_amount_repository.dart';

class IncomeRepository extends MonthlyAmountRepository {
  IncomeRepository(AppDatabase db) : super(db, 'incomes');
}
