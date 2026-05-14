import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:majstor24_app/core/auth/auth_storage.dart';
import '../role_manager.dart';

class ApiClient {

  static String get baseUrl {
    return RoleManager.baseUrl + "/";
  }

  final AuthStorage _storage = AuthStorage();

  // STATEFUL CLIENT
  final http.Client _client = http.Client();

  // COOKIE STORAGE
  final Map<String, String> _cookies = {};

  /* ==========================================
     HEADERS
  ========================================== */

  Future<Map<String, String>> _headers({bool auth = true}) async {

    final headers = {
      "Accept": "application/json",
    };

    // COOKIE
    if (_cookies.isNotEmpty) {
      final cookieString = _cookies.entries
          .map((e) => "${e.key}=${e.value}")
          .join("; ");

      headers["Cookie"] = cookieString;
      print("COOKIE SENT: $cookieString");
    }

    if (auth) {
      final token = await _storage.getToken();

      print("TOKEN FROM STORAGE: $token");

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return headers;
  }

  /* ==========================================
     GET
  ========================================== */

  Future<dynamic> get(String endpoint) async {

    final uri = Uri.parse(baseUrl + endpoint);

    print("GET: $uri");

    final res = await _client
        .get(
          uri,
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 20));

    _saveCookies(res);

    print("GET STATUS: ${res.statusCode}");
    print("GET BODY: ${res.body}");

    return await _parseResponse(res);
  }

  /* ==========================================
     POST (SVE IDE KAO JSON)
  ========================================== */

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {

    final uri = Uri.parse(baseUrl + endpoint);

    print("POST: $uri");
    print("BODY: $body");

    final headers = await _headers();

    // 🔥 SVE IDE KAO JSON (i fizicka i pravna)
    headers["Content-Type"] = "application/json";

    final res = await _client.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(const Duration(seconds: 20));

    _saveCookies(res);

    print("POST STATUS: ${res.statusCode}");
    print("POST BODY: ${res.body}");

    return await _parseResponse(res);
  }
  
  /* ==========================================
   POST ABSOLUTE URL
========================================== */

Future<dynamic> postAbsolute(
  String absoluteUrl, {
  Map<String, dynamic>? body,
}) async {

  final uri = Uri.parse(absoluteUrl);

  print("POST ABSOLUTE: $uri");
  print("BODY: $body");

  final headers = await _headers();

  headers["Content-Type"] =
      "application/json";

  final res = await _client.post(

    uri,

    headers: headers,

    body: body != null
        ? jsonEncode(body)
        : null,

  ).timeout(
    const Duration(seconds: 20),
  );

  _saveCookies(res);

  print(
    "POST ABS STATUS: ${res.statusCode}",
  );

  print(
    "POST ABS BODY: ${res.body}",
  );

  return await _parseResponse(res);
}

  /* ==========================================
     COOKIE HANDLER
  ========================================== */

  void _saveCookies(http.Response res) {

    final rawCookies = res.headers['set-cookie'];

    if (rawCookies != null) {

      final cookiesList = rawCookies.split(',');

      for (var cookie in cookiesList) {

        final parts = cookie.split(';')[0].split('=');

        if (parts.length == 2) {
          final name = parts[0].trim();
          final value = parts[1].trim();

          _cookies[name] = value;

          print("COOKIE UPDATED: $name=$value");
        }
      }
    }
  }

  /* ==========================================
     RESPONSE PARSER
  ========================================== */

  Future<dynamic> _parseResponse(http.Response res) async {

    final status = res.statusCode;

    if (status == 401) {

      print("SESSION EXPIRED → CLEAR STORAGE");

      await _storage.clearAll();
      _cookies.clear();

      throw Exception("SESSION_EXPIRED");
    }

    if (status < 200 || status >= 300) {
      throw Exception("HTTP ERROR $status");
    }

    try {
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("INVALID_JSON_RESPONSE");
    }
  }
}