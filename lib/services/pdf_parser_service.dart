import '../models/menu.dart';
import 'package:logging/logging.dart';

class PdfParserService {
  final Logger _logger = Logger('PdfParserService');

  DateTime _mondayOfDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final daysFromMonday = d.weekday - 1; // Mon=1 -> 0, Sun=7 -> 6
    return d.subtract(Duration(days: daysFromMonday));
  }

  int _isoWeek(DateTime date) {
    final monday = _mondayOfDate(date);
    final jan4 = DateTime(monday.year, 1, 4);
    final isoYearStartMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    final diffDays = monday.difference(isoYearStartMonday).inDays;
    return 1 + (diffDays ~/ 7);
  }

  List<DailyMenu> _menusKw36(DateTime monday) {
    return [
      DailyMenu(
        date: monday,
        items: [
          MenuItem(
            id: '36_mo_fleisch',
            name: 'Poulet-Cordon bleu',
            description: 'mit Pasta, Tomatensauce und Reibkäse',
            price: 0,
            category: 'fleisch',
            allergens: const ['CH'],
          ),
          MenuItem(
            id: '36_mo_veg1',
            name: 'Panada nature',
            description: 'mit Pasta, Tomatensauce und Reibkäse',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
          MenuItem(
            id: '36_mo_veg2',
            name: 'Tortelloni Tricolore',
            description: 'mit Käsefüllung, Kräuterrahmsauce',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 1)),
        items: [
          MenuItem(
            id: '36_di_fleisch',
            name: 'Schlemmerfilet Bordelaise',
            description: 'mit hausgemachter Mayonnaise und Salzkartoffeln',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '36_di_veg',
            name: 'Vegi Burger',
            description: 'mit hausgemachter Mayonnaise und Salzkartoffeln',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 2)),
        items: [
          MenuItem(
            id: '36_mi_fleisch',
            name: 'Ofenfleischkäse',
            description: 'mit Jus und Spätzli',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '36_mi_veg',
            name: 'Plant based Filet',
            description: 'an Rahmsauce mit Spätzli',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 3)),
        items: [
          MenuItem(
            id: '36_do_fleisch',
            name: 'Schweinsragout',
            description: 'an Senfsauce mit Pilawreis',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '36_do_veg',
            name: 'Veganes Geschnetzeltes',
            description: 'an Senfsauce mit Pilawreis',
            price: 0,
            category: 'vegan',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 4)),
        items: [
          MenuItem(
            id: '36_fr_fleisch',
            name: 'Schweinsragout',
            description: 'an Senfsauce mit Pilawreis',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '36_fr_veg',
            name: 'Veganes Geschnetzeltes',
            description: 'an Senfsauce mit Pilawreis',
            price: 0,
            category: 'vegan',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
    ];
  }

  List<DailyMenu> _menusKw37(DateTime monday) {
    return [
      DailyMenu(
        date: monday,
        items: [
          MenuItem(
            id: '37_mo_fleisch',
            name: 'Rindsschmorbraten',
            description: 'mit Bramata-Polenta',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '37_mo_veg',
            name: 'Rindsschmorbraten (Veggie-Alternative)',
            description: 'mit Bramata-Polenta',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 1)),
        items: [
          MenuItem(
            id: '37_di_fleisch',
            name: 'Gehacktes mit Hörnli',
            description: 'Apfelmus und Käse',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '37_di_veg',
            name: 'Vegi-Gehacktes mit Hörnli',
            description: 'Apfelmus und Käse',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 2)),
        items: [
          MenuItem(
            id: '37_mi_fleisch',
            name: 'Thai-Wok',
            description: 'mit gebratenem Reis (Fleisch-Variante)',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '37_mi_veg',
            name: 'Thai-Wok',
            description: 'mit gebratenem Reis (Vegi-Variante)',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
      // Thursday: closed -> 'Geschlossen'
      DailyMenu(
        date: monday.add(const Duration(days: 3)),
        items: const [],
        isOpen: false,
        specialNote: 'Keine Mensa',
      ),
      DailyMenu(
        date: monday.add(const Duration(days: 4)),
        items: [
          MenuItem(
            id: '37_fr_fleisch',
            name: 'Gyrosgeschnetzeltes',
            description: 'mit Couscous',
            price: 0,
            category: 'fleisch',
            allergens: const [],
          ),
          MenuItem(
            id: '37_fr_veg',
            name: 'Vegi-Gyrosgeschnetzeltes',
            description: 'mit Couscous',
            price: 0,
            category: 'vegetarisch',
            allergens: const [],
          ),
        ],
        isOpen: true,
        specialNote: null,
      ),
    ];
  }

  List<DailyMenu> _retagIdsWithKw(List<DailyMenu> menus, int kw) {
    String replacePrefix(String id) {
      if (id.startsWith('36_')) return id.replaceFirst('36_', '${kw}_');
      if (id.startsWith('37_')) return id.replaceFirst('37_', '${kw}_');
      return id;
    }

    return menus
        .map(
          (m) => DailyMenu(
            date: m.date,
            items: m.items
                .map(
                  (it) => MenuItem(
                    id: replacePrefix(it.id),
                    name: it.name,
                    description: it.description,
                    price: it.price,
                    category: it.category,
                    allergens: it.allergens,
                  ),
                )
                .toList(),
            isOpen: m.isOpen,
            specialNote: m.specialNote,
          ),
        )
        .toList();
  }

  int _templateForKw(int kw) {
    const anchorKw = 36; // anchor: KW36 uses template 36
    final isEvenOffset = ((kw - anchorKw) % 2) == 0;
    return isEvenOffset ? 36 : 37;
  }

  Future<List<DailyMenu>> convertForDate(DateTime date) async {
    final monday = _mondayOfDate(date);
    final kw = _isoWeek(date);
    final templateKw = _templateForKw(kw);
    _logger.info(
        'Dynamic parse: KW$kw (template $templateKw) from Monday ${monday.toIso8601String()}');
    final base = templateKw == 37 ? _menusKw37(monday) : _menusKw36(monday);
    return _retagIdsWithKw(base, kw);
  }
}
