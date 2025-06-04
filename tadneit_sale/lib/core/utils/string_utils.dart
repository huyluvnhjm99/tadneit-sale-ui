import 'package:intl/intl.dart';

class StringUtils {
  static String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    return formatter.format(amount);
  }
}