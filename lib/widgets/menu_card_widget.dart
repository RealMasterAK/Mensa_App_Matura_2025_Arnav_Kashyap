import 'package:flutter/cupertino.dart';
import '../models/menu.dart';
import 'package:intl/intl.dart';

/// Widget zur Anzeige eines Tagesmenüs
class MenuCardWidget extends StatelessWidget {
  final DailyMenu menu;

  const MenuCardWidget({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final isClosed = !menu.isOpen || menu.items.isEmpty;
    final dateStr = _formatDate(menu.date);

    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Semantics(
        label: 'Menü für $dateStr${isClosed ? ", geschlossen" : ""}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(dateStr),
                if (isClosed) _buildClosedState() else _buildMenuItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String dateStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: CupertinoColors.white,
      child: Text(
        dateStr,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black,
        ),
      ),
    );
  }

  Widget _buildClosedState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.lock_fill,
                size: 24,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Geschlossen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: menu.items.map(_buildMenuItem).toList(),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final categoryColor = _getCategoryColor(item.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                _buildCategoryIndicator(item.category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIndicator(String category) {
    final isFleisch = category.toLowerCase() == 'fleisch';
    final isVegetarisch = category.toLowerCase() == 'vegetarisch';
    if (!isFleisch && !isVegetarisch) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFleisch
            ? CupertinoColors.systemRed.withOpacity(0.1)
            : CupertinoColors.systemGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFleisch
              ? CupertinoColors.systemRed
              : CupertinoColors.systemGreen,
          width: 1.5,
        ),
      ),
      child: Text(
        isFleisch ? 'Fleisch' : 'Vegetarisch',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isFleisch
              ? CupertinoColors.systemRed
              : CupertinoColors.systemGreen,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    if (targetDay == today) return 'Heute';
    if (targetDay == today.add(const Duration(days: 1))) return 'Morgen';

    return DateFormat('EEEE, d. MMMM', 'de_DE').format(date);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fleisch':
        return CupertinoColors.systemRed;
      case 'vegetarisch':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}

