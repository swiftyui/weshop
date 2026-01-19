import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';
import '../models/weekly_list.dart';
import '../models/shopping_template.dart';

class StorageService {
  static const String _listKey = 'grocery_list';
  static const String _weeklyListsKey = 'weekly_lists';
  static const String _activeWeekKey = 'active_week_id';
  static const String _frequentItemsKey = 'frequent_items';
  static const String _templatesKey = 'shopping_templates';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> addItem(GroceryItem item) async {
    final items = await getAllItems();
    items.add(item);
    await _saveItems(items);
  }

  static Future<void> updateItem(GroceryItem item) async {
    final items = await getAllItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
      await _saveItems(items);
    }
  }

  static Future<void> deleteItem(String id) async {
    final items = await getAllItems();
    items.removeWhere((item) => item.id == id);
    await _saveItems(items);
  }

  static Future<List<GroceryItem>> getAllItems() async {
    final jsonString = _prefs.getString(_listKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList =
          jsonString.split('|').where((e) => e.isNotEmpty).toList();
      return jsonList.map((json) => GroceryItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveItems(List<GroceryItem> items) async {
    final jsonString = items.map((item) => item.toJson()).join('|');
    await _prefs.setString(_listKey, jsonString);
  }

  static Future<void> clearAll() async {
    await _prefs.remove(_listKey);
  }

  // Weekly Lists Management
  static Future<void> saveWeeklyList(WeeklyList weeklyList) async {
    final lists = await getAllWeeklyLists();
    final index = lists.indexWhere((l) => l.id == weeklyList.id);
    if (index != -1) {
      lists[index] = weeklyList;
    } else {
      lists.add(weeklyList);
    }
    await _saveWeeklyLists(lists);
  }

  static Future<void> deleteWeeklyList(String id) async {
    final lists = await getAllWeeklyLists();
    lists.removeWhere((list) => list.id == id);
    await _saveWeeklyLists(lists);
    
    // Also delete items associated with this week
    final key = 'grocery_list_$id';
    await _prefs.remove(key);
    
    // If this was the active week, clear active week
    if (getActiveWeekId() == id) {
      await _prefs.remove(_activeWeekKey);
    }
  }

  static Future<List<WeeklyList>> getAllWeeklyLists() async {
    final jsonString = _prefs.getString(_weeklyListsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList =
          jsonString.split('|').where((e) => e.isNotEmpty).toList();
      return jsonList.map((json) => WeeklyList.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveWeeklyLists(List<WeeklyList> lists) async {
    final jsonString = lists.map((list) => list.toJson()).join('|');
    await _prefs.setString(_weeklyListsKey, jsonString);
  }

  static Future<void> setActiveWeek(String weekId) async {
    await _prefs.setString(_activeWeekKey, weekId);
  }

  static Future<void> clearActiveWeek() async {
    await _prefs.remove(_activeWeekKey);
  }

  static String? getActiveWeekId() {
    return _prefs.getString(_activeWeekKey);
  }

  static Future<WeeklyList?> getActiveWeek() async {
    final weekId = getActiveWeekId();
    if (weekId == null) return null;
    
    final lists = await getAllWeeklyLists();
    try {
      return lists.firstWhere((l) => l.id == weekId);
    } catch (e) {
      return null;
    }
  }

  // Weekly Items Management
  static Future<void> addItemToWeek(String weekId, GroceryItem item) async {
    final items = await getItemsForWeek(weekId);
    items.add(item);
    await _saveItemsForWeek(weekId, items);
  }

  static Future<void> updateItemInWeek(String weekId, GroceryItem item) async {
    final items = await getItemsForWeek(weekId);
    final index = items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      items[index] = item;
      await _saveItemsForWeek(weekId, items);
    }
  }

  static Future<void> deleteItemFromWeek(String weekId, String itemId) async {
    final items = await getItemsForWeek(weekId);
    items.removeWhere((item) => item.id == itemId);
    await _saveItemsForWeek(weekId, items);
  }

  static Future<List<GroceryItem>> getItemsForWeek(String weekId) async {
    final key = 'grocery_list_$weekId';
    final jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList =
          jsonString.split('|').where((e) => e.isNotEmpty).toList();
      return jsonList.map((json) => GroceryItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveItemsForWeek(String weekId, List<GroceryItem> items) async {
    final key = 'grocery_list_$weekId';
    final jsonString = items.map((item) => item.toJson()).join('|');
    await _prefs.setString(key, jsonString);
  }

  // Get all items from all weeks combined
  static Future<Map<String, dynamic>> getAllItemsFromAllWeeks() async {
    final Map<String, dynamic> result = {
      'itemsWithWeeks': <Map<String, dynamic>>[],
      'legacyItems': <GroceryItem>[],
    };

    // Get legacy items (items not in any week)
    final legacyItems = await getAllItems();
    result['legacyItems'] = legacyItems;

    // Get all weekly lists
    final weeklyLists = await getAllWeeklyLists();
    
    // Get items for each week
    for (var week in weeklyLists) {
      final items = await getItemsForWeek(week.id);
      for (var item in items) {
        result['itemsWithWeeks'].add({
          'item': item,
          'week': week,
        });
      }
    }

    return result;
  }

  // Frequently Bought Items
  static Future<void> trackItemPurchase(String itemName) async {
    final frequentItems = await getFrequentItems();
    if (frequentItems.containsKey(itemName)) {
      frequentItems[itemName] = frequentItems[itemName]! + 1;
    } else {
      frequentItems[itemName] = 1;
    }
    await _saveFrequentItems(frequentItems);
  }

  static Future<Map<String, int>> getFrequentItems() async {
    final jsonString = _prefs.getString(_frequentItemsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    try {
      final Map<String, dynamic> decoded = {};
      final parts = jsonString.split('|');
      for (var part in parts) {
        if (part.isEmpty) continue;
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          decoded[keyValue[0]] = int.parse(keyValue[1]);
        }
      }
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  static Future<List<String>> getTopFrequentItems({int limit = 6}) async {
    final frequentItems = await getFrequentItems();
    final sorted = frequentItems.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  static Future<void> _saveFrequentItems(Map<String, int> items) async {
    final encoded = items.entries.map((e) => '${e.key}:${e.value}').join('|');
    await _prefs.setString(_frequentItemsKey, encoded);
  }

  // Shopping Templates
  static Future<void> saveTemplate(ShoppingTemplate template) async {
    final templates = await getAllTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
    } else {
      templates.add(template);
    }
    await _saveTemplates(templates);
  }

  static Future<void> deleteTemplate(String id) async {
    final templates = await getAllTemplates();
    templates.removeWhere((t) => t.id == id);
    await _saveTemplates(templates);
  }

  static Future<List<ShoppingTemplate>> getAllTemplates() async {
    final jsonString = _prefs.getString(_templatesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList =
          jsonString.split('|||').where((e) => e.isNotEmpty).toList();
      return jsonList.map((json) => ShoppingTemplate.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveTemplates(List<ShoppingTemplate> templates) async {
    final jsonString = templates.map((t) => t.toJson()).join('|||');
    await _prefs.setString(_templatesKey, jsonString);
  }
}