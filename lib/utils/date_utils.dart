import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    if (isSameDay(date, today)) {
      return 'Heute';
    } else if (isSameDay(date, tomorrow)) {
      return 'Morgen';
    }

    return DateFormat('EEEE, d. MMMM', 'de_DE').format(date);
  }

  static String formatShortDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('d. MMM', 'de_DE').format(date);
  }

  static String getDayOfWeek(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('E', 'de_DE').format(date);
  }

  static bool isToday(String dateString) {
    final date = DateTime.parse(dateString);
    final today = DateTime.now();
    return isSameDay(date, today);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int getWeekNumber(DateTime date) {
    final thursday =
        date.add(Duration(days: 4 - (date.weekday == 7 ? 0 : date.weekday)));
    final firstDayOfYear = DateTime(thursday.year, 1, 1);
    return ((thursday.difference(firstDayOfYear).inDays) / 7).floor() + 1;
  }

  static String getGermanDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      case 7:
        return 'Sonntag';
      default:
        return '';
    }
  }

  static String formatGermanDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

// Convenience wrappers if you prefer calling these from outside without DateUtils.
String formatDate(String date) => DateUtils.formatDate(date);
String formatDateShort(String date) =>
    DateFormat('dd.MM', 'de_DE').format(DateTime.parse(date));
String getDayOfWeek(String dateString) => DateUtils.getDayOfWeek(dateString);
