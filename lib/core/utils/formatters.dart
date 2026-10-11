import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'en_US');
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM');

  /// Formats value in Pakistani Rupees, e.g. "Rs. 1,200"
  static String formatPKR(num amount) {
    return 'Rs. ${_currencyFormat.format(amount)}';
  }

  /// Formats mileage in kilometers, e.g. "14,500 km"
  static String formatMileage(num km) {
    return '${_numberFormat.format(km)} km';
  }

  /// Formats date to "12 Oct 2026"
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats date to "12 Oct"
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Relative due string, e.g. "Due in 5 days" or "Overdue by 2 days"
  static String formatDueRelative(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) {
      return 'Due today';
    } else if (diff == 1) {
      return 'Due tomorrow';
    } else if (diff > 1) {
      return 'Due in $diff days';
    } else if (diff == -1) {
      return 'Overdue by 1 day';
    } else {
      return 'Overdue by ${diff.abs()} days';
    }
  }
}
