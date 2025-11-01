import '../models/menu.dart';

/// Filtert und sortiert Menü-Daten
class MenuFilter {
  /// Filtert Menüs nach Kategorie (Fleisch oder Vegetarisch)
  /// Wenn category null ist, werden alle Menüs zurückgegeben
  List<DailyMenu> filterByCategory(
    List<DailyMenu> menus,
    String? category,
  ) {
    if (category == null) return menus;

    return menus
        .map((menu) {
          final filteredItems = menu.items
              .where((item) => item.category.toLowerCase() == category)
              .toList();

          return DailyMenu(
            date: menu.date,
            items: filteredItems,
            isOpen: filteredItems.isNotEmpty ? menu.isOpen : false,
            specialNote: filteredItems.isEmpty
                ? 'Keine ${_getCategoryLabel(category)} Gerichte'
                : menu.specialNote,
          );
        })
        .where((menu) => menu.isOpen || menu.specialNote != null)
        .toList();
  }

  /// Filtert Menüs für einen Datumsbereich (von startDate bis endDate)
  List<DailyMenu> filterByDateRange(
    List<DailyMenu> menus,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return menus
        .where((menu) => !menu.date.isBefore(start) && !menu.date.isAfter(end))
        .toList();
  }

  /// Erstellt Platzhalter-Menüs für Tage ohne Daten
  List<DailyMenu> fillMissingDays(
    List<DailyMenu> existingMenus,
    DateTime startDate,
    DateTime endDate,
  ) {
    final result = <DailyMenu>[];
    final existingDates = existingMenus.map((m) => _getDateKey(m.date)).toSet();

    for (var date = startDate; !date.isAfter(endDate); date = date.add(const Duration(days: 1))) {
      final existingMenu = existingMenus.firstWhere(
        (m) => _isSameDay(m.date, date),
        orElse: () => DailyMenu(
          date: date,
          items: const [],
          isOpen: false,
          specialNote: date.weekday >= 6 ? 'Geschlossen' : 'Kein Menü verfügbar',
        ),
      );
      result.add(existingMenu);
    }

    return result;
  }

  /// Sortiert Menüs nach Datum (aufsteigend)
  List<DailyMenu> sortByDate(List<DailyMenu> menus) {
    final sorted = [...menus];
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  String _getCategoryLabel(String category) {
    return category == 'fleisch' ? 'Fleisch' : 'vegetarischen';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

