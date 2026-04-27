import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:majstor24_app/core/auth/auth_storage.dart';

class ApiClient {

  static const String baseUrl = "https://majstor24.ba/api/";

  final AuthStorage _storage = AuthStorage();

  /* ==========================================
     HEADERS
  ========================================== */

  Future<Map<String, String>> _headers({bool auth = true}) async {

    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };

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

    final res = await http
        .get(
          uri,
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 20));

    print("GET STATUS: ${res.statusCode}");
    print("GET BODY: ${res.body}");

    return await _parseResponse(res);

  }

  /* ==========================================
     POST
  ========================================== */

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {

    final uri = Uri.parse(baseUrl + endpoint);

    print("POST: $uri");
    print("BODY: $body");

    final res = await http
        .post(
          uri,
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 20));

    print("POST STATUS: ${res.statusCode}");
    print("POST BODY: ${res.body}");

    return await _parseResponse(res);

  }

  /* ==========================================
     RESPONSE PARSER (🔥 KLJUČNO)
  ========================================== */

  Future<dynamic> _parseResponse(http.Response res) async {

    final status = res.statusCode;

    /* 🔴 401 HANDLER */
    if (status == 401) {

      print("SESSION EXPIRED → CLEAR STORAGE");

      await _storage.clearAll();

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