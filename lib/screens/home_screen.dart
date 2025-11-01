import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/menu.dart';
import '../widgets/date_navigator.dart';
import '../widgets/menu_card_widget.dart';
import '../widgets/category_filter_button.dart';
import '../services/selected_menu_parser.dart';
import '../services/cache_service.dart';
import '../services/menu_filter.dart';
import 'package:logging/logging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SelectedMenuParser _menuService = SelectedMenuParser();
  final CacheService _cacheService = CacheService();
  final MenuFilter _menuFilter = MenuFilter();
  final _logger = Logger('HomeScreen');

  List<DailyMenu> _menus = [];
  bool _isLoading = true;
  String? _error;
  DateTime? _selectedDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMenus());
  }

  DateTime _getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<List<DailyMenu>> _fetchMenusForDate(DateTime date) async {
    try {
      final monday = _getMondayOfWeek(date);
      final nextMonday = monday.add(const Duration(days: 7));

      // Cache aufräumen
      await _cacheService.removeOlderThan(monday);

      // Aktuelle Woche laden (aus Cache oder neu)
      var currentWeekMenus = await _cacheService.getCachedMenusForWeek(monday);
      if (currentWeekMenus == null) {
        currentWeekMenus = await _menuService.fetchMenusForDate(date);
        await _cacheService.cacheMenusForWeek(monday, currentWeekMenus);
      }

      // Nächste Woche im Hintergrund laden
      var nextWeekMenus = await _cacheService.getCachedMenusForWeek(nextMonday);
      if (nextWeekMenus == null) {
        nextWeekMenus = await _menuService.fetchMenusForDate(nextMonday);
        await _cacheService.cacheMenusForWeek(nextMonday, nextWeekMenus);
      }

      return currentWeekMenus;
    } catch (e) {
      _logger.severe('Error fetching menus: $e');
      return [];
    }
  }

  Future<void> _loadMenus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final targetDate = _selectedDate ?? DateTime.now();
      final menus = await _fetchMenusForDate(targetDate);
      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.severe('Error loading menus: $e', e, stackTrace);
      setState(() {
        _error = 'Fehler beim Laden der Menüs';
        _isLoading = false;
      });
    }
  }

  List<DailyMenu> get _filteredMenus {
    List<DailyMenu> menusToShow;

    if (_selectedDate == null) {
      // Alle Menüs anzeigen, sortiert nach Datum
      menusToShow = _menuFilter.sortByDate(_menus);
    } else {
      // Menüs für die Woche ab dem ausgewählten Datum
      final startDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final monday = _getMondayOfWeek(startDate);
      final sunday = monday.add(const Duration(days: 6));

      final menusInRange =
          _menuFilter.filterByDateRange(_menus, startDate, sunday);
      menusToShow =
          _menuFilter.fillMissingDays(menusInRange, startDate, sunday);
    }

    // Kategorie-Filter anwenden
    return _menuFilter.filterByCategory(menusToShow, _selectedCategory);
  }

  Future<void> _onRefresh() async {
    await _cacheService.clearCache();
    await _loadMenus();
  }

  Widget _buildSkeletonList() => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i == 2 ? 16.0 : 12.0),
                  child: Container(
                      height: [20.0, 16.0, 16.0][i],
                      width: [160.0, double.infinity, 220.0][i],
                      color: CupertinoColors.systemGrey6),
                ),
              )..add(Row(
                  children: [
                    Container(
                        height: 22.0,
                        width: 80.0,
                        color: CupertinoColors.systemGrey6),
                    const SizedBox(width: 8),
                    Container(
                        height: 22.0,
                        width: 60.0,
                        color: CupertinoColors.systemGrey6),
                  ],
                )),
            ),
          ),
          childCount: 4,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: _onRefresh),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 13),
                height: 40,
                alignment: Alignment.center,
                child: const Text(
                  'Mensa KSWE',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(2, 2, 22, 4),
                child: Row(
                  children: [
                    CategoryFilterButton(
                      label: 'Fleisch',
                      category: 'fleisch',
                      color: Colors.red,
                      isSelected: _selectedCategory == 'fleisch',
                      onPressed: () => setState(() {
                        _selectedCategory =
                            _selectedCategory == 'fleisch' ? null : 'fleisch';
                      }),
                    ),
                    const SizedBox(width: 0),
                    CategoryFilterButton(
                      label: 'Vegetarisch',
                      category: 'vegetarisch',
                      color: Colors.green,
                      isSelected: _selectedCategory == 'vegetarisch',
                      onPressed: () => setState(() {
                        _selectedCategory = _selectedCategory == 'vegetarisch'
                            ? null
                            : 'vegetarisch';
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DateNavigator(
                  initialDate: _selectedDate,
                  onDateChanged: (d) {
                    setState(() => _selectedDate = d);
                    _loadMenus();
                  },
                ),
              ),
            ),
            if (_isLoading)
              _buildSkeletonList()
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 32,
                            color: CupertinoColors.systemRed),
                      ),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(
                              fontSize: 17, color: CupertinoColors.label),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        onPressed: _loadMenus,
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredMenus.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.doc_text_search,
                            size: 32, color: CupertinoColors.systemGrey),
                      ),
                      const SizedBox(height: 16),
                      const Text('Keine Menüs verfügbar',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Bitte versuchen Sie es später erneut',
                          style: TextStyle(
                              fontSize: 17,
                              color: CupertinoColors.secondaryLabel),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: const Text(
                    'Tagesmenüs',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      MenuCardWidget(menu: _filteredMenus[index]),
                  childCount: _filteredMenus.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
