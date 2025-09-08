import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu.dart';
import 'pdf_parser_service.dart';
import 'package:logging/logging.dart';

class MenuService {
  static const String _cacheKey = 'menu_cache';
  static const String _lastUpdateKey = 'menu_last_update';

  final Logger _logger = Logger('MenuService');
  final PdfParserService _pdf = PdfParserService();

  DateTime _mondayOf(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return x.subtract(Duration(days: x.weekday - 1));
  }

  int _isoWeek(DateTime date) {
    final monday = _mondayOf(date);
    final jan4 = DateTime(monday.year, 1, 4);
    final isoYearStartMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    final diffDays = monday.difference(isoYearStartMonday).inDays;
    return 1 + (diffDays ~/ 7);
  }

  String buildLoewenscheuneUrlForDate(DateTime date) {
    final kw = _isoWeek(date);
    return 'https://www.loewenscheune.ch/assets/documents/Menüplan_Woche_${kw}.pdf';
  }

  String _weekKey(DateTime date) {
    final monday = _mondayOf(date);
    final normalizedMonday = DateTime(monday.year, monday.month, monday.day);
    return normalizedMonday.toIso8601String();
  }

  Future<Map<String, List<DailyMenu>>> _readCacheWeeks() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKey);
    if (cachedJson == null) return <String, List<DailyMenu>>{};
    try {
      final decoded = json.decode(cachedJson);
      if (decoded is Map<String, dynamic>) {
        final weeks = <String, List<DailyMenu>>{};
        for (final entry in decoded.entries) {
          final key = entry.key;
          final value = entry.value;
          if (value is List) {
            weeks[key] = value.map((e) => DailyMenu.fromJson(e)).toList();
          }
        }
        return weeks;
      }
    } catch (e, st) {
      _logger.warning('Failed to parse cache, will reset. Error: $e', e, st);
    }
    return <String, List<DailyMenu>>{};
  }

  Future<void> _writeCacheWeeks(Map<String, List<DailyMenu>> weeks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = <String, dynamic>{};
    for (final entry in weeks.entries) {
      jsonMap[entry.key] = entry.value.map((m) => m.toJson()).toList();
    }
    await prefs.setString(_cacheKey, json.encode(jsonMap));
    await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    _logger.info('Cached weeks: ${weeks.keys.join(', ')}');
  }

  Future<List<DailyMenu>> getMenus() async {
    return getMenusForDate(DateTime.now());
  }

  Future<List<DailyMenu>> getMenusForDate(DateTime date) async {
    try {
      final monday = _mondayOf(date);
      final nextMonday = monday.add(const Duration(days: 7));
      final kw = _isoWeek(date);
      final url = buildLoewenscheuneUrlForDate(date);
      _logger.info(
          'Weekly load: selected=${date.toIso8601String()} monday=${monday.toIso8601String()} KW$kw url=$url');

      // Read cache
      final weeks = await _readCacheWeeks();

      // Prune past weeks (keep from current monday and future)
      final keysToRemove = <String>[];
      for (final key in weeks.keys) {
        try {
          final keyDate = DateTime.parse(key);
          if (keyDate.isBefore(monday)) {
            keysToRemove.add(key);
          }
        } catch (_) {}
      }
      for (final k in keysToRemove) {
        weeks.remove(k);
      }

      // Ensure requested week exists
      final currentKey = _weekKey(date);
      if (!weeks.containsKey(currentKey)) {
        final generated = await _pdf.convertForDate(date);
        weeks[currentKey] = generated
            .map((m) => DailyMenu(
                  date: DateTime(monday.year, monday.month, monday.day).add(
                      Duration(
                          days: m.date.difference(_mondayOf(m.date)).inDays)),
                  items: m.items,
                  isOpen: m.isOpen,
                  specialNote: m.specialNote,
                ))
            .toList();
        _logger.info('Generated ${generated.length} menus for KW$kw');
      } else {
        _logger.info('Using cached menus for KW$kw');
      }

      // Ensure next week exists
      final nextKey = _weekKey(nextMonday);
      if (!weeks.containsKey(nextKey)) {
        final nextMenus = await _pdf.convertForDate(nextMonday);
        weeks[nextKey] = nextMenus
            .map((m) => DailyMenu(
                  date: DateTime(
                          nextMonday.year, nextMonday.month, nextMonday.day)
                      .add(Duration(
                          days: m.date.difference(_mondayOf(m.date)).inDays)),
                  items: m.items,
                  isOpen: m.isOpen,
                  specialNote: m.specialNote,
                ))
            .toList();
        _logger.info(
            'Pre-generated next week (${nextMonday.toIso8601String()}) with ${nextMenus.length} menus');
      }

      // Write cache back
      await _writeCacheWeeks(weeks);

      // Return requested week
      return weeks[currentKey] ?? [];
    } catch (e, stackTrace) {
      _logger.severe('Error getting menus: $e', e, stackTrace);
      return [];
    }
  }

  Future<List<DailyMenu>?> _getCachedMenus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);
      final now = DateTime.now().millisecondsSinceEpoch;
      if (lastUpdate == null || now - lastUpdate > 3600000) {
        _logger.info('Cache is expired or missing');
        return null;
      }
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData == null) {
        _logger.info('No cached data found');
        return null;
      }
      final List<dynamic> jsonData = json.decode(cachedData);
      final menus = jsonData.map((json) => DailyMenu.fromJson(json)).toList();
      _logger.info('Found ${menus.length} menus in cache');
      return menus;
    } catch (e, stackTrace) {
      _logger.severe('Error reading cache: $e', e, stackTrace);
      return null;
    }
  }

  Future<void> _cacheMenus(List<DailyMenu> menus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = menus.map((m) => m.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonData));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
      _logger.info('Cached ${menus.length} menus');
    } catch (e, stackTrace) {
      _logger.severe('Error caching menus: $e', e, stackTrace);
    }
  }

  Future<void> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastUpdateKey);
  }
}
