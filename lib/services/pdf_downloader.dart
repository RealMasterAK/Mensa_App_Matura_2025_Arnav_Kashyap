import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// Service zum Herunterladen von Mensa-Menü-PDFs
class PdfDownloader {
  final Logger _logger = Logger('PdfDownloader');

  /// Lädt das PDF für eine bestimmte Woche herunter
  /// Gibt die PDF-Bytes zurück oder null bei Fehler
  Future<List<int>?> downloadMenuPdf(int weekNumber) async {
    try {
      final url =
          'https://www.loewenscheune.ch/assets/documents/Menüplan_Woche_$weekNumber.pdf';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        _logger.warning('PDF Download failed: Status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.severe('Error downloading PDF: $e');
      return null;
    }
  }

  /// Berechnet die ISO-Wochennummer für ein Datum
  int calculateWeekNumber(DateTime date) {
    final monday = _getMondayOfWeek(date);
    final jan4 = DateTime(monday.year, 1, 4);
    final isoStart = jan4.subtract(Duration(days: jan4.weekday - 1));
    return 1 + (monday.difference(isoStart).inDays ~/ 7);
  }

  /// Gibt den Montag der Woche zurück, in der das Datum liegt
  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
