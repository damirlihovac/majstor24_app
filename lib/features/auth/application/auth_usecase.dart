import '../domain/auth_repository.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  /// Mora vratiti PHPSESSID iz login response headera
  Future<String> login(String identifier, String password) async {
    return repository.login(identifier, password);
  }
}