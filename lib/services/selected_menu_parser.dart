import '../models/menu.dart';
import 'pdf_downloader.dart';
import 'text_extractor.dart';
import 'text_sorter.dart';
import 'package:logging/logging.dart';

/// Hauptservice für das Abrufen von Mensa-Menüs
/// Koordiniert Download, Text-Extraktion und Parsing
class SelectedMenuParser {
  final Logger _logger = Logger('SelectedMenuParser');
  final PdfDownloader _downloader = PdfDownloader();
  final TextExtractor _textExtractor = TextExtractor();
  final TextSorter _parser = TextSorter();

  /// Lädt und parst die Menüs für ein bestimmtes Datum
  /// Gibt die Menüs der Woche zurück, in der das Datum liegt
  Future<List<DailyMenu>> fetchMenusForDate(DateTime date) async {
    try {
      // Montag der Woche berechnen
      final monday = _getMondayOfWeek(date);

      // Wochennummer ermitteln
      final weekNumber = _downloader.calculateWeekNumber(date);

      // PDF herunterladen
      final pdfBytes = await _downloader.downloadMenuPdf(weekNumber);
      if (pdfBytes == null) {
        return _createClosedMenus(monday);
      }

      // Text aus PDF extrahieren
      final text = _textExtractor.extractText(pdfBytes);
      if (text.isEmpty) {
        return _createClosedMenus(monday);
      }

      // Text in Menüs parsen
      return _parser.parseMenus(text, monday);
    } catch (e) {
      _logger.severe('Error fetching menus: $e');
      return _createClosedMenus(_getMondayOfWeek(date));
    }
  }

  /// Erstellt Menüs mit "Geschlossen"-Status für eine Woche
  List<DailyMenu> _createClosedMenus(DateTime monday) {
    return List.generate(
      5,
      (i) => DailyMenu(
        date: monday.add(Duration(days: i)),
        items: const [],
        isOpen: false,
        specialNote: 'Geschlossen',
      ),
    );
  }

  /// Gibt den Montag der Woche zurück, in der das Datum liegt
  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
