import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';

class StorageService {
  static const String _listKey = 'grocery_list';
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
}
