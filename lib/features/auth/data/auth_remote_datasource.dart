import 'package:majstor24_app/core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  final ApiClient _api;

  AuthRemoteDataSourceImpl(this._api);

  @override
  Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {

    final res = await _api.post(
      "login.php",
      body: {
        "identifier": identifier,
        "password": password,
      },
    );

    return res;
  }
}