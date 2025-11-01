import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Button zum Filtern nach Kategorie (Fleisch/Vegetarisch)
class CategoryFilterButton extends StatelessWidget {
  final String label;
  final String category;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryFilterButton({
    super.key,
    required this.label,
    required this.category,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 52),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.8), width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.9),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

