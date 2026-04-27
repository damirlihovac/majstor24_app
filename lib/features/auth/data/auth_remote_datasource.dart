import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class AuthRemoteDataSource {
  Future<String> login(String identifier, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<String> login(String identifier, String password) async {
    final response = await client.post(
      Uri.parse('https://majstor24.ba/api/login.php'),
      headers: {
        "Content-Type": "application/json",
        "X-Client": "mobile",
      },
      body: jsonEncode({
        "identifier": identifier,
        "password": password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("LOGIN_FAILED");
    }

    final data = jsonDecode(response.body);

    if (data["success"] != true || data["token"] == null) {
      throw Exception("SESSION_EXPIRED");
    }

    return data["token"];
  }
}