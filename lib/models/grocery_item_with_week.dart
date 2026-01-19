import 'grocery_item.dart';
import 'weekly_list.dart';

class GroceryItemWithWeek {
  final GroceryItem item;
  final WeeklyList? week; // null for legacy items

  GroceryItemWithWeek({
    required this.item,
    this.week,
  });
}
