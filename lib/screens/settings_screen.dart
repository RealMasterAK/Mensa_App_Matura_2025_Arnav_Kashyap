import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import '../services/menu_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Logger _logger = Logger('SettingsScreen');
  final MenuService _menuService = MenuService();
  bool _busy = false;
  late String _currentWeekUrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekUrl = _menuService.buildLoewenscheuneUrlForDate(now);
  }

  Future<void> _refreshWeek() async {
    setState(() => _busy = true);
    try {
      await _menuService.forceRefresh();
    } catch (e) {
      _logger.severe('Refresh failed', e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Einstellungen'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aktuelle Menü-Quelle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _currentWeekUrl,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: _busy ? null : _refreshWeek,
                child: _busy
                    ? const CupertinoActivityIndicator()
                    : const Text('Cache leeren & neu laden'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Hinweis',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'Die App lädt automatisch den Menüplan der Kalenderwoche, die dem ausgewählten Datum entspricht.',
                style: TextStyle(color: CupertinoColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
