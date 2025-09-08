class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> allergens;
  final int? calories;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.allergens,
    this.calories,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: json['price'].toDouble(),
        category: json['category'],
        allergens: List<String>.from(json['allergens']),
        calories: json['calories'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'allergens': allergens,
        'calories': calories,
      };
}

class DailyMenu {
  final DateTime date;
  final List<MenuItem> items;
  final bool isOpen;
  final String? specialNote;

  DailyMenu({
    required this.date,
    required this.items,
    required this.isOpen,
    this.specialNote,
  });

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    return DailyMenu(
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      isOpen: json['isOpen'],
      specialNote: json['specialNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'isOpen': isOpen,
      'specialNote': specialNote,
    };
  }
}

class MensaInfo {
  final String name;
  final String location;
  final OpeningHours openingHours;

  MensaInfo({
    required this.name,
    required this.location,
    required this.openingHours,
  });

  factory MensaInfo.fromJson(Map<String, dynamic> json) => MensaInfo(
        name: json['name'],
        location: json['location'],
        openingHours: OpeningHours.fromJson(json['openingHours']),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'openingHours': openingHours.toJson(),
      };
}

class OpeningHours {
  final String weekdays;
  final String saturday;
  final String sunday;

  OpeningHours({
    required this.weekdays,
    required this.saturday,
    required this.sunday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        weekdays: json['weekdays'],
        saturday: json['saturday'],
        sunday: json['sunday'],
      );

  Map<String, dynamic> toJson() => {
        'weekdays': weekdays,
        'saturday': saturday,
        'sunday': sunday,
      };
}
