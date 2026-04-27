import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  static const _storage = FlutterSecureStorage();

  static String? _memoryToken;

  // 🔹 GET TOKEN (prvo iz memorije, fallback storage)
  static Future<String?> getToken() async {
    if (_memoryToken != null) return _memoryToken;

    _memoryToken = await _storage.read(key: 'token');
    return _memoryToken;
  }

  // 🔹 SAVE TOKEN
  static Future<void> setToken(String token) async {
    _memoryToken = token;
    await _storage.write(key: 'token', value: token);
  }

  // 🔹 LOGOUT
  static Future<void> clear() async {
    _memoryToken = null;
    await _storage.deleteAll();
  }
}