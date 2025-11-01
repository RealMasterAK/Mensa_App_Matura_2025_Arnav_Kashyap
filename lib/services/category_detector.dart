/// Erkennt, ob ein Gericht zur Kategorie "Fleisch" gehört
class CategoryDetector {
  static const _fleischKeywords = [
    'poulet',
    'brätchügeli',
    'fleischkäse',
    'fischstäbli',
    'fisch',
    'lachs',
    'wurst',
    'schinken',
    'hackfleisch',
    'rind',
    'kalb',
    'pork',
    'speck',
    'bacon',
    'salami',
    'fleischbällchen',
    'cordon bleu',
    'burgunderart',
    'rinds-',
    'gyros',
    'fleisch'
  ];

  /// Prüft, ob der übergebene Text ein Fleischgericht beschreibt
  static bool isFleisch(String dishText) {
    final lower = dishText.toLowerCase();
    return _fleischKeywords.any((keyword) => lower.contains(keyword));
  }

  /// Bestimmt die Kategorie eines Gerichts (fleisch oder vegetarisch)
  static String detectCategory(String dishText) {
    return isFleisch(dishText) ? 'fleisch' : 'vegetarisch';
  }
}
