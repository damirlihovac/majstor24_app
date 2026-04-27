abstract class AuthRepository {
  Future<String> login(String identifier, String password);
}