import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = "auth_token";
  static const _keyContactId = "contact_id";

  static Future<void> saveSession({
    required String token,
    required String contactId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyContactId, value: contactId);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<String?> getContactId() async {
    return await _storage.read(key: _keyContactId);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}