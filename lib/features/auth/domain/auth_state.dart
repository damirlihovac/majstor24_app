import '../data/models/auth_user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthUserModel? user;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthUserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}
