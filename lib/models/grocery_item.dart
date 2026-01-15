import 'dart:convert';

class GroceryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final bool isChecked;
  final DateTime createdAt;
  final double? estimatedPrice;
  final String? notes;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.unit = 'pcs',
    this.isChecked = false,
    required this.createdAt,
    this.estimatedPrice,
    this.notes,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    bool? isChecked,
    DateTime? createdAt,
    double? estimatedPrice,
    String? notes,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'createdAt': createdAt.toIso8601String(),
      'estimatedPrice': estimatedPrice,
      'notes': notes,
    };
  }

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Other',
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? 'pcs',
      isChecked: map['isChecked'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      estimatedPrice: map['estimatedPrice']?.toDouble(),
      notes: map['notes'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory GroceryItem.fromJson(String source) =>
      GroceryItem.fromMap(jsonDecode(source));
}
