import 'package:shared_preferences/shared_preferences.dart';

class CacheClient {
  static late SharedPreferences _sharedPrefs;
  static Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  static Future<void> setBool(String key, bool value) async {
    await _sharedPrefs.setBool(key, value);
  }

  static bool getBool(String key) {
    return _sharedPrefs.getBool(key) ?? false;
  }

  static Future<void> setString(String key, String value) async {
    await _sharedPrefs.setString(key, value);
  }

  static String getString(String key, {String? defaultValue}) {
    return _sharedPrefs.getString(key) ?? defaultValue ?? '';
  }

  static Future<void> removeString(String key) async {
    await _sharedPrefs.remove(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _sharedPrefs.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return _sharedPrefs.getStringList(key) ?? const <String>[];
  }

  static Future<void> clearCachedData() async {
    await _sharedPrefs.clear();
  }
}
