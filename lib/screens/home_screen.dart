import 'package:flutter/cupertino.dart';
import '../models/menu.dart';
import '../widgets/menu_card.dart';
import '../widgets/date_navigator.dart';
import '../services/menu_service.dart';
import '../utils/app_localizations.dart';
import 'package:logging/logging.dart';
import '../widgets/filter_bar.dart';
import '../services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuService _menuService = MenuService();
  final PreferencesService _prefs = PreferencesService();
  final _logger = Logger('HomeScreen');
  List<DailyMenu> _menus = [];
  bool _isLoading = true;
  String? _error;

  // Filters/search
  Set<String> _filters = <String>{};
  String _query = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing HomeScreen');
    _restoreState().then((_) => _loadMenus());
  }

  Future<void> _restoreState() async {
    final savedDate = await _prefs.getSelectedDate();
    final savedFilters = await _prefs.getDietaryFilters();
    // Remove unsupported filters like 'halal'
    savedFilters.remove('halal');
    setState(() {
      _selectedDate = savedDate;
      _filters = savedFilters;
    });
  }

  Future<void> _persistState() async {
    if (_selectedDate != null) {
      await _prefs.saveSelectedDate(_selectedDate!);
    }
    await _prefs.saveDietaryFilters(_filters);
  }

  Future<void> _loadMenus() async {
    _logger.info('Starting to load menus');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _logger.info('Calling MenuService.getMenusForDate()');
      final target = _selectedDate ?? DateTime.now();
      final menus = await _menuService.getMenusForDate(target);
      _logger.info('Received ${menus.length} menus from service');

      setState(() {
        _menus = menus;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.severe('Error loading menus: $e', e, stackTrace);
      setState(() {
        _error = AppLocalizations.of(context).errorLoadingMenus;
        _isLoading = false;
      });
    }
  }

  List<DailyMenu> get _filteredMenus {
    List<DailyMenu> base = [..._menus];

    // If a date is selected, only apply filter if there are menus on/after that date
    if (_selectedDate != null) {
      final hasOnOrAfter = base.any((m) => !m.date.isBefore(_selectedDate!));
      if (hasOnOrAfter) {
        base = base.where((m) => !m.date.isBefore(_selectedDate!)).toList();
      }
    }

    if (_filters.isNotEmpty) {
      base = base
          .map((daily) {
            final items = daily.items.where((item) {
              final cat = item.category.toLowerCase();
              bool ok = true;
              if (_filters.contains('vegan')) {
                ok = ok && (cat == 'vegan');
              }
              if (_filters.contains('vegetarisch')) {
                ok = ok && (cat == 'vegetarisch');
              }
              // Allergen exclusions
              if (_filters.contains('glutenfrei')) {
                ok = ok &&
                    !item.allergens.map((e) => e.toUpperCase()).contains('A');
              }
              if (_filters.contains('lactosefrei')) {
                ok = ok &&
                    !item.allergens.map((e) => e.toUpperCase()).contains('G');
              }
              return ok;
            }).toList();
            return DailyMenu(
                date: daily.date,
                items: items,
                isOpen: daily.isOpen,
                specialNote: daily.specialNote);
          })
          .where((d) => d.items.isNotEmpty)
          .toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      base = base
          .map((daily) {
            final items = daily.items
                .where((item) =>
                    item.name.toLowerCase().contains(q) ||
                    item.description.toLowerCase().contains(q))
                .toList();
            return DailyMenu(
                date: daily.date,
                items: items,
                isOpen: daily.isOpen,
                specialNote: daily.specialNote);
          })
          .where((d) => d.items.isNotEmpty)
          .toList();
    }

    // Enforce at most one red (fleisch) and one green (vegetarisch) per day
    base = base
        .map((daily) {
          MenuItem? red;
          MenuItem? green;
          for (final item in daily.items) {
            final cat = item.category.toLowerCase();
            if (cat == 'fleisch' && red == null) {
              red = item;
            } else if (cat == 'vegetarisch' && green == null) {
              green = item;
            }
            if (red != null && green != null) break;
          }
          final kept = <MenuItem>[];
          if (red != null) kept.add(red!);
          if (green != null) kept.add(green!);
          return DailyMenu(
              date: daily.date,
              items: kept,
              isOpen: daily.isOpen,
              specialNote: daily.specialNote);
        })
        .where((d) => d.items.isNotEmpty)
        .toList();

    // Sort by date ascending
    base.sort((a, b) => a.date.compareTo(b.date));

    return base;
  }

  Widget _buildSkeletonList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 20, width: 160, color: CupertinoColors.systemGrey6),
                const SizedBox(height: 12),
                Container(
                    height: 16,
                    width: double.infinity,
                    color: CupertinoColors.systemGrey6),
                const SizedBox(height: 8),
                Container(
                    height: 16, width: 220, color: CupertinoColors.systemGrey6),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                        height: 22,
                        width: 80,
                        color: CupertinoColors.systemGrey6),
                    const SizedBox(width: 8),
                    Container(
                        height: 22,
                        width: 60,
                        color: CupertinoColors.systemGrey6),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: 4,
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _menuService.forceRefresh();
    await _loadMenus();
  }

  @override
  Widget build(BuildContext context) {
    _logger.info(
        'Building HomeScreen - isLoading: $_isLoading, error: $_error, menuCount: ${_menus.length}');

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: _onRefresh),

            // In-page title
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 13),
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          AppLocalizations.of(context).appTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(8),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/settings'),
                          child: const Icon(
                            CupertinoIcons.settings,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search/filter bar at very top
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: FilterBar(
                  selectedFilters: _filters,
                  onFiltersChanged: (f) {
                    setState(() => _filters = f);
                    _persistState();
                  },
                  searchQuery: _query,
                  onSearchChanged: (q) => setState(() => _query = q),
                ),
              ),
            ),

            // Date selector below search
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DateNavigator(
                  initialDate: _selectedDate,
                  onDateChanged: (d) {
                    setState(() => _selectedDate = d);
                    _persistState();
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
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed.withValues(
                                red: 0, green: 0, blue: 0, alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 32,
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 17,
                            color: CupertinoColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: _loadMenus,
                          child: Text(AppLocalizations.of(context).retry),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_filteredMenus.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey.withValues(
                                red: 0, green: 0, blue: 0, alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.doc_text_search,
                            size: 32,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).noMenusAvailable,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).pleaseTryLater,
                          style: const TextStyle(
                            fontSize: 17,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    AppLocalizations.of(context).dailyMenus,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final menu = _filteredMenus[index];
                    return MenuCard(menu: menu);
                  },
                  childCount: _filteredMenus.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}
