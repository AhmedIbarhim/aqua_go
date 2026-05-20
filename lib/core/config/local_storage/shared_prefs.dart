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

  static String getString(String key) {
    return _sharedPrefs.getString(key) ?? '';
  }

  static Future<void> removeString(String key) async {
    await _sharedPrefs.remove(key);
  }

  static Future<void> clearCachedData() async {
    await _sharedPrefs.clear();
  }
}
