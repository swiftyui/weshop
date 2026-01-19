import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _currencyKey = 'currency';
  static const String _currencySymbolKey = 'currency_symbol';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setCurrency(String currencyCode, String symbol) async {
    await _prefs.setString(_currencyKey, currencyCode);
    await _prefs.setString(_currencySymbolKey, symbol);
  }

  static String getCurrencyCode() {
    return _prefs.getString(_currencyKey) ?? 'USD';
  }

  static String getCurrencySymbol() {
    return _prefs.getString(_currencySymbolKey) ?? '\$';
  }
}
