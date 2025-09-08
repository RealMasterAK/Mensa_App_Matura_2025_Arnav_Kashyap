import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _selectedDateKey = 'selected_date_iso';
  static const String _dietaryFiltersKey = 'dietary_filters';
  static const String _allergenAlertsKey = 'allergen_alerts';

  Future<void> saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDateKey, date.toIso8601String());
  }

  Future<DateTime?> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_selectedDateKey);
    if (iso == null) return null;
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDietaryFilters(Set<String> filters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dietaryFiltersKey, filters.toList());
  }

  Future<Set<String>> getDietaryFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dietaryFiltersKey);
    return list?.toSet() ?? <String>{};
  }

  Future<void> saveAllergenAlerts(Set<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_allergenAlertsKey, allergens.toList());
  }

  Future<Set<String>> getAllergenAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_allergenAlertsKey);
    return list?.toSet() ?? <String>{};
  }
}
