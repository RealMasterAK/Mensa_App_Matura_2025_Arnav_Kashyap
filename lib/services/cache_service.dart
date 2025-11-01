import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu.dart';
import 'package:logging/logging.dart';

/// Verwaltet das lokale Caching von Menü-Daten
class CacheService {
  final Logger _logger = Logger('CacheService');
  static const _cacheKey = 'menu_cache';

  /// Speichert Menüs für eine Woche im Cache
  /// Der Key ist der ISO8601-String des Montags der Woche
  Future<void> cacheMenusForWeek(DateTime weekMonday, List<DailyMenu> menus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allCachedWeeks = await _readAllCachedWeeks();
      final weekKey = weekMonday.toIso8601String();
      
      allCachedWeeks[weekKey] = menus;
      await _writeAllCachedWeeks(allCachedWeeks);
    } catch (e) {
      _logger.warning('Error caching menus: $e');
    }
  }

  /// Liest gecachte Menüs für eine Woche
  /// Gibt null zurück, wenn keine Daten im Cache sind
  Future<List<DailyMenu>?> getCachedMenusForWeek(DateTime weekMonday) async {
    try {
      final allCachedWeeks = await _readAllCachedWeeks();
      final weekKey = weekMonday.toIso8601String();
      return allCachedWeeks[weekKey];
    } catch (e) {
      _logger.warning('Error reading cache: $e');
      return null;
    }
  }

  /// Liest alle gecachten Wochen aus dem Cache
  Future<Map<String, List<DailyMenu>>> _readAllCachedWeeks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    
    if (cachedJson == null) return {};
    
    try {
      final decoded = json.decode(cachedJson);
      if (decoded is Map<String, dynamic>) {
        return decoded.map(
          (key, value) => MapEntry(
            key,
            (value as List)
                .map((item) => DailyMenu.fromJson(item))
                .toList(),
          ),
        );
      }
    } catch (e) {
      _logger.warning('Cache parse error: $e');
    }
    
    return {};
  }

  /// Schreibt alle gecachten Wochen in den Cache
  Future<void> _writeAllCachedWeeks(
    Map<String, List<DailyMenu>> cachedWeeks,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = cachedWeeks.map(
      (key, value) => MapEntry(
        key,
        value.map((menu) => menu.toJson()).toList(),
      ),
    );
    await prefs.setString(_cacheKey, json.encode(jsonMap));
  }

  /// Entfernt veraltete Einträge aus dem Cache (älter als das gegebene Datum)
  Future<void> removeOlderThan(DateTime cutoffDate) async {
    try {
      final allCachedWeeks = await _readAllCachedWeeks();
      final cutoffMonday = _getMondayOfWeek(cutoffDate);
      
      allCachedWeeks.removeWhere((key, _) {
        final weekDate = DateTime.tryParse(key);
        return weekDate != null && weekDate.isBefore(cutoffMonday);
      });
      
      await _writeAllCachedWeeks(allCachedWeeks);
    } catch (e) {
      _logger.warning('Error cleaning cache: $e');
    }
  }

  /// Löscht den gesamten Cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      _logger.warning('Error clearing cache: $e');
    }
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}

