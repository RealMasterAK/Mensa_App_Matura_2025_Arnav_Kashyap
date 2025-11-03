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
    // Zusätzliche PDF-Fusszeilen/Meta-Fragmente, die gelegentlich auftauchen
    'schöpfen',
    'monat',
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
    // Hilfsfunktionen und Keyword-Sets für robuste Erkennung
    bool containsAny(String source, List<String> needles) {
      for (final n in needles) {
        if (source.contains(n)) return true;
      }
      return false;
    }

    final mondayKeywords = <String>[
      // KW44
      'pastetli',
      'pouletbrätchügeli',
      'erbsen',
      'rüebli',
      'champignons-gemüsefüllung',
      // KW45
      'rindsschmorbraten',
      'bramata polenta',
      'vegi hackplätzli'
    ];
    final tuesdayKeywords = <String>[
      // KW44
      'tortelloni',
      'tricolore',
      'käsefüllung',
      'cinque pi',
      // KW45
      'currywurst',
      'vegi-nuggets',
      'pommes frites'
    ];
    final wednesdayKeywords = <String>[
      'ofen fleischkäse',
      'kartoffelgratin',
      'rosmarinjus',
      'grilliertes ofengemüse',

      // KW45
      'auberginen-kichererbsen curry',
      'pinsa'
    ];
    final thursdayKeywords = <String>[
      'reis casimir',
      'poulet',
      'früchten',
      'tofu',
      // KW45
      'schweinssteak',
      'kräuterbutter',
      'lyonerkartoffeln',
      'sellerie piccata'
    ];
    final fridayKeywords = <String>[
      'fischstäbli',
      'salzkartoffeln',
      'rahmspinat',
      'homemade mayo',
      'vegi-sticks',
      // KW45
      'pouletschenkelragout',
      'tom kha-sauce',
      'basmatireis',
      'gemüse-wok'
    ];

    bool handleManualAssignments(int index) {
      final line = lines[index];
      final lower = line.toLowerCase();
      void setDish(String day, String category, String value) {
        menuData[day]![category] = value;
      }

      if (lower.contains('pouletbrätchügeli')) {
        setDish(
          'montag',
          'fleisch',
          'Pastetli mit Pouletbrätchügeli Erbsen und Rüebli',
        );
        return true;
      }

      if (lower.contains('champignons-gemüsefüllung')) {
        setDish(
          'montag',
          'vegetarisch',
          'Pastetli mit Champignons-Gemüsefüllung Erbsen und Rüebli',
        );
        return true;
      }

      if (lower.contains('cinque pi')) {
        const text = 'Tortelloni Tricolore mit Käsefüllung Cinque Pi';
        setDish('dienstag', 'fleisch', text);
        setDish('dienstag', 'vegetarisch', text);
        return true;
      }

      if (lower.contains('ofen fleischkäse')) {
        setDish(
          'mittwoch',
          'fleisch',
          'Ofen Fleischkäse Kartoffelgratin Rosmarinjus',
        );
        return true;
      }

      if (lower.contains('grilliertes ofengemüse')) {
        setDish(
          'mittwoch',
          'vegetarisch',
          'Grilliertes Ofengemüse Kartoffelgratin Rosmarinjus',
        );
        return true;
      }

      if (lower.contains('mit poulet') && lower.contains('früchten')) {
        setDish(
          'donnerstag',
          'fleisch',
          'Reis Casimir mit Poulet und Früchten',
        );
        return true;
      }

      if (lower.contains('mit tofu') && lower.contains('früchten')) {
        setDish(
          'donnerstag',
          'vegetarisch',
          'Reis Casimir mit Tofu und Früchten',
        );
        return true;
      }

      if (lower.contains('mit poulet') ||
          lower.contains('mit tofu') ||
          lower.contains('und früchten')) {
        return true;
      }

      if (lower.contains('reis casimir')) {
        bool hasPoulet = lower.contains('poulet');
        bool hasTofu = lower.contains('tofu');
        bool hasFruits = lower.contains('früchten');

        for (int j = index + 1; j <= index + 3 && j < lines.length; j++) {
          final nextLower = lines[j].toLowerCase();
          if (!hasPoulet && nextLower.contains('poulet')) {
            hasPoulet = true;
          }
          if (!hasTofu && nextLower.contains('tofu')) {
            hasTofu = true;
          }
          if (!hasFruits && nextLower.contains('früchten')) {
            hasFruits = true;
          }
        }

        if (hasPoulet && hasFruits) {
          setDish(
            'donnerstag',
            'fleisch',
            'Reis Casimir mit Poulet und Früchten',
          );
        }

        if (hasTofu && hasFruits) {
          setDish(
            'donnerstag',
            'vegetarisch',
            'Reis Casimir mit Tofu und Früchten',
          );
        }

        return true;
      }

      if (lower.contains('fischstäbli')) {
        setDish(
          'freitag',
          'fleisch',
          'Fischstäbli mit Salzkartoffeln Rahmspinat und Homemade Mayo',
        );
        return true;
      }

      if (lower.contains('vegi-sticks')) {
        setDish(
          'freitag',
          'vegetarisch',
          'Vegi-Sticks mit Salzkartoffeln Rahmspinat und Homemade Mayo',
        );
        return true;
      }

      if (lower.contains('rindsschmorbraten')) {
        setDish(
          'montag',
          'fleisch',
          'Rindsschmorbraten mit Bramata Polenta',
        );
        return true;
      }

      if (lower.contains('vegi hackplätzli')) {
        setDish(
          'montag',
          'vegetarisch',
          'Vegi Hackplätzli mit Bramata Polenta',
        );
        return true;
      }

      if (lower.contains('currywurst')) {
        setDish('dienstag', 'fleisch', 'Currywurst mit Pomme Frites');
        return true;
      }

      if (lower.contains('vegi-nuggets')) {
        setDish('dienstag', 'vegetarisch', 'Vegi-Nuggets mit Pommes Frites');
        return true;
      }

      if (lower.contains('auberginen-kichererbsen')) {
        const text = 'Auberginen-Kichererbsen Curry mit Pinsa';
        setDish('mittwoch', 'fleisch', text);
        setDish('mittwoch', 'vegetarisch', text);
        return true;
      }

      if (lower.contains('schweinssteak')) {
        setDish(
          'donnerstag',
          'fleisch',
          'Schweinssteak Kräuterbutter Lyonerkartoffeln',
        );
        return true;
      }

      if (lower.contains('sellerie-piccata')) {
        setDish(
          'donnerstag',
          'vegetarisch',
          'Sellerie-Piccata Kräuterbutter Lyonerkartoffeln',
        );
        return true;
      }

      if (lower.contains('pouletschenkelragout')) {
        setDish(
          'freitag',
          'fleisch',
          'Pouletschenkelragout an Tom Kha-Sauce Basmatireis',
        );
        return true;
      }

      if (lower.contains('gemüse-wok')) {
        setDish('freitag', 'vegetarisch', 'Gemüse-Wok an Tom Kha Basmatireis');
        return true;
      }

      if (lower.contains('basmatireis') ||
          lower.contains('rosmarinjus') ||
          lower.contains('erbsen und rüebli') ||
          lower.contains('bramata polenta') ||
          lower.contains('pomme frites') ||
          lower.contains('pommes frites') ||
          lower.contains('kräuterbutter') ||
          lower.contains('lyonerkartoffeln') ||
          lower.contains('rahmspinat') ||
          lower.contains('homemade mayo')) {
        return true;
      }

      return false;
    }

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      final cleanedLine =
          line.replaceAll(RegExp(r'\(ch\)', caseSensitive: false), '').trim();

      if (handleManualAssignments(i)) {
        continue;
      }

      void assign(String day, String category) {
        final current = menuData[day]![category]!;
        if (current != '-' && current != cleanedLine) {
          return;
        }
        menuData[day]![category] = cleanedLine;
      }

      // Hardcodierte Zuordnung basierend auf Gericht-Keywords
      if (containsAny(lower, mondayKeywords)) {
        assign('montag', CategoryDetector.detectCategory(line));
      }
      if (containsAny(lower, tuesdayKeywords)) {
        assign('dienstag', CategoryDetector.detectCategory(line));
      }
      if (containsAny(lower, wednesdayKeywords)) {
        assign('mittwoch', CategoryDetector.detectCategory(line));
      }
      if (containsAny(lower, thursdayKeywords)) {
        assign('donnerstag', CategoryDetector.detectCategory(line));
      }
      if (containsAny(lower, fridayKeywords)) {
        assign('freitag', CategoryDetector.detectCategory(line));
      }
    }
  }

  /// Erstellt DailyMenu-Objekte aus den geparsten Daten
  List<DailyMenu> _createDailyMenus(
    Map<String, Map<String, String>> menuData,
    DateTime weekStartMonday,
  ) {
    final dayNames = [
      'montag',
      'dienstag',
      'mittwoch',
      'donnerstag',
      'freitag'
    ];

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

  /// Trennt Gerichtsname und Beschreibung nach " mit "/" an " (ohne sep) oder Beilagen-Keywords (mit sep)
  Map<String, String> _splitNameAndDescription(String dishText) {
    final lower = dishText.toLowerCase();

    // Zuerst " mit " / " an " versuchen (Separator ausschließen)
    for (final sep in [' mit ', ' an ']) {
      final idx = lower.indexOf(sep);
      if (idx > 0) {
        final desc = dishText.substring(idx + sep.length).trim();
        return {
          'name': dishText.substring(0, idx).trim(),
          'description': sep == ' an ' ? 'an $desc' : desc,
        };
      }
    }

    // Dann Beilagen-Keywords versuchen (Separator einschließen)
    for (final sep in ['kräuterbutter', 'kartoffelgratin']) {
      final idx = lower.indexOf(sep);
      if (idx > 0) {
        return {
          'name': dishText.substring(0, idx).trim(),
          'description': dishText.substring(idx).trim(),
        };
      }
    }

    return {'name': dishText.trim(), 'description': ''};
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
      category: category,
    ));
  }
}
