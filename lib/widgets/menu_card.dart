import 'package:flutter/cupertino.dart';
import '../models/menu.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/allergens.dart';

class MenuCard extends StatelessWidget {
  final DailyMenu menu;

  const MenuCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final bool noteClosed =
        (menu.specialNote?.toLowerCase().contains('keine mensa') ?? false);
    final bool isClosed = !menu.isOpen || menu.items.isEmpty || noteClosed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date
            Row(
              children: [
                Expanded(
                  child: Text(
                    date_utils.formatDate(menu.date.toIso8601String()),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ],
            ),

            // Closed state
            if (isClosed) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Geschlossen',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),

              // Menu items
              ...menu.items.map((item) => _buildMenuItem(context, item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: _getCategoryColor(item.category),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Menu item content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showDetails(context, item),
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel,
                      height: 1.3,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Additional info row
                Row(
                  children: [
                    // Category badge (pastel background, black text)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category)
                            .withValues(alpha: 26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryLabel(item.category),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),

                    // Allergen chips as emoji-only (skip gluten)
                    if (item.allergens.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.allergens
                              .where((a) => a.toUpperCase() != 'A')
                              .map((a) {
                            final meta = resolveAllergen(a);
                            return Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemYellow
                                    .withValues(alpha: 26),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: CupertinoColors.systemYellow
                                      .withValues(alpha: 77),
                                  width: 0.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(meta.emoji,
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, MenuItem item) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gerichtdetails',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fertig'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category)
                            .withValues(alpha: 26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryLabel(item.category),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fleisch':
        return CupertinoColors.systemRed; // pastel when alpha applied
      case 'vegetarisch':
        return CupertinoColors.systemGreen; // pastel when alpha applied
      case 'vegan':
        return CupertinoColors.systemTeal;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'fleisch':
        return 'Fleisch';
      case 'vegetarisch':
        return 'Vegetarisch';
      case 'vegan':
        return 'Vegan';
      default:
        return 'Sonstiges';
    }
  }
}
