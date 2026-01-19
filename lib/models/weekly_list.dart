import 'dart:convert';

class WeeklyList {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final bool isActive;

  WeeklyList({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.isActive = false,
  });

  WeeklyList copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return WeeklyList(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    });
  }

  factory WeeklyList.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return WeeklyList(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? false,
    );
  }

  String getDateRange() {
    final start = '${startDate.month}/${startDate.day}';
    final end = '${endDate.month}/${endDate.day}';
    return '$start - $end';
  }

  bool isCurrentWeek() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}
