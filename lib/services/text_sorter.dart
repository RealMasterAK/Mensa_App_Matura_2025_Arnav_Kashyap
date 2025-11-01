import '../models/menu.dart';
import 'category_detector.dart';

/// Parsed Text aus PDFs in strukturierte Menü-Daten
class TextSorter {
  static const _noiseKeywords = [
    'menüplan',
    'unser fleisch',
    'klosterstrasse',
    'genossenschaft',
    'täglich gibt',
    'buffet',
    'salate',
    'wo ',
    'vom ',
  ];

  /// Konvertiert rohen PDF-Text in eine Liste von Tagesmenüs
  List<DailyMenu> parseMenus(String rawText, DateTime weekStartMonday) {
    // Text in Zeilen aufteilen und filtern
    final lines = _extractRelevantLines(rawText);

    // Menü-Datenstruktur initialisieren
    final menuData = _initializeMenuData();

    // Gerichte den Wochentagen zuordnen
    _assignDishesToDays(lines, menuData);

    // Menü-Objekte erstellen
    return _createDailyMenus(menuData, weekStartMonday);
  }

  /// Extrahiert relevante Zeilen aus dem Text und filtert Noise
  List<String> _extractRelevantLines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => !_isNoise(line))
        .toList();
  }

  /// Prüft, ob eine Zeile "Noise" ist und ignoriert werden sollte
  bool _isNoise(String line) {
    final lower = line.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'fleisch' ||
        lower == 'vegetarisch' ||
        _noiseKeywords.any((keyword) => lower.contains(keyword)) ||
        line.length < 3;
  }

  /// Initialisiert die Menü-Datenstruktur für eine Woche
  Map<String, Map<String, String>> _initializeMenuData() {
    return {
      'montag': {'fleisch': '-', 'vegetarisch': '-'},
      'dienstag': {'fleisch': '-', 'vegetarisch': '-'},
      'mittwoch': {'fleisch': '-', 'vegetarisch': '-'},
      'donnerstag': {'fleisch': '-', 'vegetarisch': '-'},
      'freitag': {'fleisch': '-', 'vegetarisch': '-'},
    };
  }

  /// Ordnet Gerichte den passenden Wochentagen zu
  void _assignDishesToDays(
    List<String> lines,
    Map<String, Map<String, String>> menuData,
  ) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      final cleanedLine = line.replaceAll('(CH)', '').trim();

      void assign(String day, String category) {
        menuData[day]![category] = cleanedLine;
      }

      // Hardcodierte Zuordnung basierend auf Gericht-Keywords
      if (lower.contains('pastetli')) {
        assign('montag', CategoryDetector.detectCategory(line));
      }
      if (lower.contains('tortelloni')) {
        assign('dienstag', CategoryDetector.detectCategory(line));
      }
      if (lower.contains('fleischkäse')) {
        assign('mittwoch', 'fleisch');
      }
      if (lower.contains('ofengemüse')) {
        assign('mittwoch', 'vegetarisch');
      }
      if (lower.contains('reis casimir') && lower.contains('poulet')) {
        assign('donnerstag', 'fleisch');
      }
      if (lower.contains('reis casimir') && lower.contains('tofu')) {
        assign('donnerstag', 'vegetarisch');
      }
      if (lower.contains('fischstäbli')) {
        assign('freitag', 'fleisch');
      }
      if (lower.contains('vegi-sticks')) {
        assign('freitag', 'vegetarisch');
      }
    }
  }

  /// Erstellt DailyMenu-Objekte aus den geparsten Daten
  List<DailyMenu> _createDailyMenus(
    Map<String, Map<String, String>> menuData,
    DateTime weekStartMonday,
  ) {
    final dayNames = ['montag', 'dienstag', 'mittwoch', 'donnerstag', 'freitag'];

    return List.generate(5, (dayIndex) {
      final dayName = dayNames[dayIndex];
      final date = weekStartMonday.add(Duration(days: dayIndex));
      final items = <MenuItem>[];

      // Fleisch-Gericht hinzufügen
      _addDishIfPresent(
        items,
        menuData[dayName]!['fleisch']!,
        'fleisch',
        date,
      );

      // Vegetarisches Gericht hinzufügen
      _addDishIfPresent(
        items,
        menuData[dayName]!['vegetarisch']!,
        'vegetarisch',
        date,
      );

      return DailyMenu(
        date: date,
        items: items,
        isOpen: items.isNotEmpty,
        specialNote: items.isEmpty ? 'Geschlossen' : null,
      );
    });
  }

  /// Fügt ein Gericht zur Liste hinzu, falls vorhanden
  void _addDishIfPresent(
    List<MenuItem> items,
    String dishText,
    String category,
    DateTime date,
  ) {
    if (dishText == '-' || dishText.isEmpty) return;

    final dishParts = _splitNameAndDescription(dishText);
    items.add(MenuItem(
      id: '${date.millisecondsSinceEpoch}_$category',
      name: dishParts['name']!,
      description: dishParts['description']!,
      price: 11,
      category: category,
    ));
  }

  /// Trennt Gerichtsname und Beschreibung (z.B. "Pastetli, Erbsen" → name: "Pastetli", description: "Erbsen")
  Map<String, String> _splitNameAndDescription(String dishText) {
    final commaIndex = dishText.indexOf(',');
    if (commaIndex > 0) {
      return {
        'name': dishText.substring(0, commaIndex).trim(),
        'description': dishText.substring(commaIndex + 1).trim(),
      };
    }
    return {'name': dishText, 'description': ''};
  }
}

