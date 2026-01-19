import 'dart:convert';

class ShoppingTemplate {
  final String id;
  final String name;
  final String icon;
  final List<TemplateItem> items;

  ShoppingTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory ShoppingTemplate.fromMap(Map<String, dynamic> map) {
    return ShoppingTemplate(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      items: List<TemplateItem>.from(map['items']?.map((x) => TemplateItem.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingTemplate.fromJson(String source) => ShoppingTemplate.fromMap(json.decode(source));
}

class TemplateItem {
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double? estimatedPrice;

  TemplateItem({
    required this.name,
    required this.category,
    this.quantity = 1,
    this.unit = 'pcs',
    this.estimatedPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'estimatedPrice': estimatedPrice,
    };
  }

  factory TemplateItem.fromMap(Map<String, dynamic> map) {
    return TemplateItem(
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      unit: map['unit'],
      estimatedPrice: map['estimatedPrice']?.toDouble(),
    );
  }
}
