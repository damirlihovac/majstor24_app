import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'PHPSESSID';

  static Future<void> saveSession(String sessionId) async {
    await _storage.write(key: _sessionKey, value: sessionId);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: _sessionKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}