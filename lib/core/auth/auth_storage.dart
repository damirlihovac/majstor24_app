import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {

  static const _tokenKey = "auth_token";
  static const _streetKey = "mailingstreet";
  static const _zipKey = "mailingzip";
  static const _cityKey = "mailingcity";
  static const _contactIdKey = "contact_id";

  static const _secure = FlutterSecureStorage();

  String? _memoryToken;

  /* ================= TOKEN ================= */

  Future<void> saveToken(String token) async {
    _memoryToken = token;
    await _secure.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    if (_memoryToken != null) return _memoryToken;
    _memoryToken = await _secure.read(key: _tokenKey);
    return _memoryToken;
  }

  /* ================= ADDRESS ================= */

  Future<void> saveAddress(
    String street,
    String zip,
    String city,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_streetKey, street);
    await prefs.setString(_zipKey, zip);
    await prefs.setString(_cityKey, city);
  }

  Future<String?> getMailingStreet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_streetKey);
  }

  Future<String?> getMailingZip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_zipKey);
  }

  Future<String?> getMailingCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  Future<Map<String, String?>> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "street": prefs.getString(_streetKey),
      "zip": prefs.getString(_zipKey),
      "city": prefs.getString(_cityKey),
    };
  }

  /* ================= CONTACT ================= */

  Future<void> saveContactId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactIdKey, id);
  }

  Future<String?> getContactId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_contactIdKey);
  }

  /* ================= CLEAR ================= */

  Future<void> clearAll() async {
    _memoryToken = null;

    final prefs = await SharedPreferences.getInstance();

    await _secure.delete(key: _tokenKey);

    await prefs.remove(_streetKey);
    await prefs.remove(_zipKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_contactIdKey);
  }
}