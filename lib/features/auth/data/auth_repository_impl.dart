import '../domain/auth_repository.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<String> login(String identifier, String password) {
    return remote.login(identifier, password);
  }
}