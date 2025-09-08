import 'package:flutter/cupertino.dart';

class AllergenMeta {
  final String code;
  final String name;
  final String emoji;
  final Color color;

  const AllergenMeta({
    required this.code,
    required this.name,
    required this.emoji,
    required this.color,
  });
}

// Common canteen codes (DE):
// A Gluten, B Crustaceans, C Egg, D Fish, E Peanuts, F Soy, G Milk,
// H Nuts, I Celery, J Mustard, K Sesame, L Sulphites, M Lupins, N Molluscs/Shellfish
const Map<String, AllergenMeta> kAllergenByCode = {
  'A': AllergenMeta(
      code: 'A',
      name: 'Gluten',
      emoji: '🌾',
      color: CupertinoColors.activeOrange),
  'B': AllergenMeta(
      code: 'B',
      name: 'Krebstiere',
      emoji: '🦐',
      color: CupertinoColors.systemPink),
  'C': AllergenMeta(
      code: 'C', name: 'Ei', emoji: '🥚', color: CupertinoColors.systemYellow),
  'D': AllergenMeta(
      code: 'D', name: 'Fisch', emoji: '🐟', color: CupertinoColors.activeBlue),
  'E': AllergenMeta(
      code: 'E',
      name: 'Erdnüsse',
      emoji: '🥜',
      color: CupertinoColors.systemOrange),
  'F': AllergenMeta(
      code: 'F', name: 'Soja', emoji: '🫘', color: CupertinoColors.systemGreen),
  'G': AllergenMeta(
      code: 'G', name: 'Milch', emoji: '🥛', color: CupertinoColors.systemTeal),
  'H': AllergenMeta(
      code: 'H',
      name: 'Schalenfrüchte',
      emoji: '🌰',
      color: CupertinoColors.systemBrown),
  'I': AllergenMeta(
      code: 'I',
      name: 'Sellerie',
      emoji: '🥬',
      color: CupertinoColors.systemGreen),
  'J': AllergenMeta(
      code: 'J',
      name: 'Senf',
      emoji: '🧴',
      color: CupertinoColors.systemYellow),
  'K': AllergenMeta(
      code: 'K',
      name: 'Sesam',
      emoji: '🌿',
      color: CupertinoColors.systemOrange),
  'L': AllergenMeta(
      code: 'L',
      name: 'Sulfite',
      emoji: '🧪',
      color: CupertinoColors.systemPurple),
  'M': AllergenMeta(
      code: 'M',
      name: 'Lupinen',
      emoji: '🌼',
      color: CupertinoColors.systemIndigo),
  'N': AllergenMeta(
      code: 'N',
      name: 'Weichtiere',
      emoji: '🐚',
      color: CupertinoColors.systemBlue),
};

AllergenMeta resolveAllergen(String codeOrName) {
  // Normalize input
  final key = codeOrName.trim();
  if (kAllergenByCode.containsKey(key)) return kAllergenByCode[key]!;

  // Try by case-insensitive name match
  final lower = key.toLowerCase();
  for (final meta in kAllergenByCode.values) {
    if (meta.name.toLowerCase() == lower) return meta;
  }

  // Fallback to unknown generic
  return AllergenMeta(
    code: key,
    name: key,
    emoji: '❓',
    color: CupertinoColors.systemGrey,
  );
}
