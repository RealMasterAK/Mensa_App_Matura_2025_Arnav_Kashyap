import 'package:flutter_test/flutter_test.dart';
import 'package:learnskill/data/mock_data.dart';
import 'package:learnskill/models/menu.dart';

void main() {
  group('MockData Tests', () {
    test('getMockMenus returns non-empty list', () {
      final menus = MockData.getMockMenus();
      expect(menus, isNotEmpty);
      expect(menus, isA<List<DailyMenu>>());
    });

    test('getMockMenus returns menus for weekdays only', () {
      final menus = MockData.getMockMenus();
      for (final menu in menus) {
        expect(menu.date.weekday, isNot(DateTime.saturday));
        expect(menu.date.weekday, isNot(DateTime.sunday));
      }
    });

    test('each menu has items', () {
      final menus = MockData.getMockMenus();
      for (final menu in menus) {
        expect(menu.items, isNotEmpty);
        expect(menu.isOpen, isTrue);
      }
    });

    test('menu items have required fields', () {
      final menus = MockData.getMockMenus();
      for (final menu in menus) {
        for (final item in menu.items) {
          expect(item.id, isNotEmpty);
          expect(item.name, isNotEmpty);
          expect(item.description, isNotEmpty);
          expect(item.price, isPositive);
          expect(item.category, isNotEmpty);
          expect(item.allergens, isA<List<String>>());
        }
      }
    });

    test('getMensaInfo returns valid info', () {
      final mensaInfo = MockData.getMensaInfo();
      expect(mensaInfo.name, 'Mensa KSWE');
      expect(mensaInfo.location, 'Löwenscheune, Bern');
      expect(mensaInfo.openingHours.weekdays, '11:30 - 14:00');
      expect(mensaInfo.openingHours.saturday, 'Geschlossen');
      expect(mensaInfo.openingHours.sunday, 'Geschlossen');
    });
  });
}
