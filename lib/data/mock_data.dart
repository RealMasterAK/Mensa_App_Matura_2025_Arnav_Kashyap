import '../models/menu.dart';

class MockData {
  static List<DailyMenu> getMockMenus() {
    final now = DateTime.now();
    final menus = <DailyMenu>[];

    // Generate menus for the next 14 days (skip weekends)
    for (int i = 0; i < 14; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }
      menus.add(DailyMenu(
        date: date,
        items: _getMenuItemsForDay(date.weekday),
        isOpen: true,
        specialNote: null,
      ));
    }

    return menus;
  }

  static List<MenuItem> _getMenuItemsForDay(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return [
          MenuItem(
            id: 'monday_1',
            name: 'Schnitzel Wiener Art',
            description: 'Fleischgericht mit Pommes und Salat',
            price: 8.50,
            category: 'fleisch',
            allergens: ['A', 'C', 'G'],
            calories: 650,
          ),
          MenuItem(
            id: 'monday_2',
            name: 'Vegetarische Lasagne',
            description: 'Mit Spinat und Ricotta',
            price: 7.20,
            category: 'vegetarisch',
            allergens: ['A', 'G'],
            calories: 480,
          ),
          MenuItem(
            id: 'monday_3',
            name: 'Gemüsesuppe',
            description: 'Hausgemachte Suppe des Tages',
            price: 3.80,
            category: 'vegetarisch',
            allergens: ['A', 'C'],
            calories: 120,
          ),
        ];

      case DateTime.tuesday:
        return [
          MenuItem(
            id: 'tuesday_1',
            name: 'Rindergulasch',
            description: 'Mit Spätzle und Rotkohl',
            price: 9.20,
            category: 'fleisch',
            allergens: ['A', 'C'],
            calories: 720,
          ),
          MenuItem(
            id: 'tuesday_2',
            name: 'Quinoa Bowl',
            description: 'Mit Avocado, Tomaten und Feta',
            price: 6.80,
            category: 'vegetarisch',
            allergens: ['A', 'G'],
            calories: 420,
          ),
          MenuItem(
            id: 'tuesday_3',
            name: 'Kartoffelsuppe',
            description: 'Cremige Suppe mit Lauch',
            price: 3.50,
            category: 'vegetarisch',
            allergens: ['A', 'C'],
            calories: 180,
          ),
        ];

      case DateTime.wednesday:
        return [
          MenuItem(
            id: 'wednesday_1',
            name: 'Hähnchenbrust',
            description: 'Mit Reis und Gemüse',
            price: 8.80,
            category: 'fleisch',
            allergens: ['A', 'C'],
            calories: 580,
          ),
          MenuItem(
            id: 'wednesday_2',
            name: 'Falafel Wrap',
            description: 'Mit Hummus und Salat',
            price: 6.50,
            category: 'vegetarisch',
            allergens: ['A', 'C', 'G'],
            calories: 380,
          ),
          MenuItem(
            id: 'wednesday_3',
            name: 'Minestrone',
            description: 'Italienische Gemüsesuppe',
            price: 4.20,
            category: 'vegetarisch',
            allergens: ['A', 'C', 'G'],
            calories: 150,
          ),
        ];

      case DateTime.thursday:
        return [
          MenuItem(
            id: 'thursday_1',
            name: 'Schweinebraten',
            description: 'Mit Kartoffelklößen und Sauerkraut',
            price: 9.50,
            category: 'fleisch',
            allergens: ['A', 'C'],
            calories: 780,
          ),
          MenuItem(
            id: 'thursday_2',
            name: 'Ratatouille',
            description: 'Provenzalische Gemüsepfanne',
            price: 6.20,
            category: 'vegetarisch',
            allergens: ['A'],
            calories: 320,
          ),
          MenuItem(
            id: 'thursday_3',
            name: 'Linsensuppe',
            description: 'Mit Würstchen (optional)',
            price: 4.80,
            category: 'vegetarisch',
            allergens: ['A', 'C'],
            calories: 200,
          ),
        ];

      case DateTime.friday:
        return [
          MenuItem(
            id: 'friday_1',
            name: 'Fischfilet',
            description: 'Mit Kartoffeln und Gemüse',
            price: 10.20,
            category: 'fleisch',
            allergens: ['A', 'D', 'F'],
            calories: 520,
          ),
          MenuItem(
            id: 'friday_2',
            name: 'Vegetarische Curry',
            description: 'Mit Reis und Naan-Brot',
            price: 7.80,
            category: 'vegetarisch',
            allergens: ['A', 'C', 'G'],
            calories: 450,
          ),
          MenuItem(
            id: 'friday_3',
            name: 'Tomaten-Basilikum Suppe',
            description: 'Mit Croutons',
            price: 3.90,
            category: 'vegetarisch',
            allergens: ['A', 'C', 'G'],
            calories: 160,
          ),
        ];

      default:
        return [];
    }
  }

  static MensaInfo getMensaInfo() {
    return MensaInfo(
      name: 'Mensa KSWE',
      location: 'Löwenscheune, Bern',
      openingHours: OpeningHours(
        weekdays: '11:30 - 14:00',
        saturday: 'Geschlossen',
        sunday: 'Geschlossen',
      ),
    );
  }
}
