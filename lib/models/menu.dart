class MenuItem {
  final String id, name, description, category;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        category: json['category'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
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

  factory DailyMenu.fromJson(Map<String, dynamic> json) => DailyMenu(
        date: DateTime.parse(json['date']),
        items:
            (json['items'] as List).map((e) => MenuItem.fromJson(e)).toList(),
        isOpen: json['isOpen'],
        specialNote: json['specialNote'],
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'isOpen': isOpen,
        if (specialNote != null) 'specialNote': specialNote,
      };
}
