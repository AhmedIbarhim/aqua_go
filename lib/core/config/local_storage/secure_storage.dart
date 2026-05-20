import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> saveSecuredString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecuredString(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecuredString(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecuredData() async {
    await _secureStorage.deleteAll();
  }
}
