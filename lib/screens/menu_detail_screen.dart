import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../utils/date_utils.dart' as date_utils;
import '../utils/app_localizations.dart';
import '../widgets/menu_card.dart';
import '../services/menu_service.dart';

class MenuDetailScreen extends StatefulWidget {
  final String date;

  const MenuDetailScreen({super.key, required this.date});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final MenuService _menuService = MenuService();
  DailyMenu? _menu;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final menus = await _menuService.getMenus();
      final dateObj = DateTime.parse(widget.date);
      final menu = menus.firstWhere(
        (m) =>
            m.date.year == dateObj.year &&
            m.date.month == dateObj.month &&
            m.date.day == dateObj.day,
        orElse: () => DailyMenu(
          date: dateObj,
          items: [],
          isOpen: false,
          specialNote: AppLocalizations.of(context).noMenuAvailable,
        ),
      );
      setState(() {
        _menu = menu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).errorLoadingMenu;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).menuDetails),
            Text(
              date_utils.formatDate(widget.date),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_menu!.isOpen)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_outline,
                                  size: 32,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Mensa Geschlossen',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _menu!.specialNote ??
                                    'Die Mensa ist an diesem Tag geschlossen.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        if (_menu!.specialNote != null)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              border: const Border(
                                left: BorderSide(
                                  color: Colors.orange,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _menu!.specialNote!,
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Available Items',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        ..._menu!.items.map((item) => MenuCard(
                            menu: DailyMenu(
                                date: _menu!.date,
                                items: [item],
                                isOpen: _menu!.isOpen,
                                specialNote: _menu!.specialNote))),
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Menu Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow('Total Items',
                                  _menu!.items.length.toString()),
                              _buildSummaryRow(
                                'Price Range',
                                '€${_getMinPrice(_menu!.items).toStringAsFixed(2)} - €${_getMaxPrice(_menu!.items).toStringAsFixed(2)}',
                              ),
                              _buildSummaryRow(
                                'Categories',
                                _getCategories(_menu!.items),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  double _getMinPrice(List<MenuItem> items) {
    if (items.isEmpty) return 0;
    return items
        .map((e) => e.price)
        .reduce((value, element) => value < element ? value : element);
  }

  double _getMaxPrice(List<MenuItem> items) {
    if (items.isEmpty) return 0;
    return items
        .map((e) => e.price)
        .reduce((value, element) => value > element ? value : element);
  }

  String _getCategories(List<MenuItem> items) {
    final categories = items.map((e) => e.category).toSet().toList();
    return categories.join(', ');
  }
}
