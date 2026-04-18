import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double amount, {String symbol = 'KM', String locale = 'bs_BA'}) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    ).format(amount);
  }
}
