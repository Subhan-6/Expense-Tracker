import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final NumberFormat _money =
      NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);

  static String money(double v) => _money.format(v);
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String month(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String monthKey(DateTime d) => DateFormat('yyyy-MM').format(d);
}
