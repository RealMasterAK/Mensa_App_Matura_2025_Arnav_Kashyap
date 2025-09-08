import 'package:flutter/cupertino.dart';

class FilterBar extends StatelessWidget {
  final Set<String> selectedFilters;
  final ValueChanged<Set<String>> onFiltersChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const FilterBar({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoSearchTextField(
          placeholder: 'Gerichte suchen',
          onChanged: onSearchChanged,
          onSubmitted: onSearchChanged,
          autocorrect: false,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip(context, 'vegan'),
              const SizedBox(width: 8),
              _buildChip(context, 'vegetarisch'),
              const SizedBox(width: 8),
              _buildChip(context, 'glutenfrei'),
              const SizedBox(width: 8),
              _buildChip(context, 'lactosefrei'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String key) {
    final bool isSelected = selectedFilters.contains(key);
    final Color accent = CupertinoColors.activeBlue;
    final Color bg =
        isSelected ? accent.withValues(alpha: 26) : CupertinoColors.systemGrey5;
    final Color fg = isSelected ? CupertinoColors.label : CupertinoColors.label;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      minSize: 0,
      color: bg,
      borderRadius: BorderRadius.circular(16),
      onPressed: () {
        final next = <String>{...selectedFilters};
        if (isSelected) {
          next.remove(key);
        } else {
          next.add(key);
        }
        onFiltersChanged(next);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _labelFor(key),
            style: TextStyle(
              color: fg, // selected: black (label), unselected: label
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(String key) {
    switch (key) {
      case 'vegan':
        return 'Vegan';
      case 'vegetarisch':
        return 'Vegetarisch';
      case 'glutenfrei':
        return 'Glutenfrei';
      case 'lactosefrei':
        return 'Laktosefrei';
      default:
        return key;
    }
  }
}
