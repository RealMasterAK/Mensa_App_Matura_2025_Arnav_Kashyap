import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:logging/logging.dart';

/// Extrahiert und bereinigt Text aus PDF-Dateien
class TextExtractor {
  final Logger _logger = Logger('TextExtractor');

  /// Extrahiert Text aus PDF-Bytes und korrigiert Zeilenumbrüche
  /// die Wörter fälschlicherweise trennen (z.B. "M\nontag" → "Montag")
  String extractText(List<int> pdfBytes) {
    try {
      final doc = PdfDocument(inputBytes: pdfBytes);
      final buffer = StringBuffer();

      // Text von allen Seiten extrahieren
      for (int i = 0; i < doc.pages.count; i++) {
        buffer.writeln(PdfTextExtractor(doc)
            .extractText(startPageIndex: i, endPageIndex: i));
      }

      doc.dispose();
      String text = buffer.toString();

      // Debug: Rohen extrahierten Text loggen
      _logger.info('unreparierter Rohtext:\n$text');

      // Zeilenumbrüche innerhalb von Wörtern korrigieren
      text = _fixWordBreaks(text);

      return text;
    } catch (e) {
      return '';
    }
  }

  /// Korrigiert Zeilenumbrüche, die mitten in Wörtern stehen
  String _fixWordBreaks(String text) {
    // Allgemeine Korrektur: Großbuchstabe gefolgt von Zeilenumbruch und Kleinbuchstabe
    text = text.replaceAllMapped(
      RegExp(r'([A-Z])\s*\n\s*([a-zäöüß])'),
      (match) => '${match[1]}${match[2]}',
    );

    // Spezifische Korrekturen für Wochentage
    final weekdayPatterns = [
      RegExp(r'([Mm])\s*\n\s*(ontag)', multiLine: true),
      RegExp(r'([Dd])\s*\n\s*(ienstag)', multiLine: true),
      RegExp(r'([Mm])\s*\n\s*(ittwoch)', multiLine: true),
      RegExp(r'([Dd])\s*\n\s*(onnerstag)', multiLine: true),
      RegExp(r'([Ff])\s*\n\s*(reitag)', multiLine: true),
    ];

    for (final pattern in weekdayPatterns) {
      text = text.replaceAllMapped(
        pattern,
        (match) => '${match[1]}${match[2]}',
      );
    }

    return text;
  }
}
