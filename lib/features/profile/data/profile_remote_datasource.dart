import '../../../core/network/api_client.dart';

class ProfileRemoteDatasource {

  final ApiClient _apiClient;

  ProfileRemoteDatasource(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async {

    final response = await _apiClient.get('profile/get.php');

    print('[PROFILE][RAW RESPONSE] $response');

    if (response['success'] != true) {
      return {};
    }

    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {};
  }
}