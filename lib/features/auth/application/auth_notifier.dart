import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/core/auth/auth_storage.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final AuthStorage _storage = AuthStorage();

  AuthState _state = const AuthState();

  AuthState get state => _state;
  bool get isLoggedIn => _state.isAuthenticated;

  String? _contactId;
  String? get contactId => _contactId;

  /*
  =============================
  INIT
  =============================
  */
Future<void> init() async {
  final token = await _storage.getToken();

  if (token != null && token.isNotEmpty) {
    try {
      final res = await _api.get("profile/dashboard.php");

      if (res["success"] == true) {
        _contactId = res["profile"]?["contactid"]?.toString();

        debugPrint("INIT CONTACT_ID: $_contactId");

        _state = _state.copyWith(
          isAuthenticated: true,
        );
      }
    } catch (e) {
      debugPrint("INIT ERROR: $e");

await _storage.clearAll();
    }
  }

  notifyListeners();
}

  /*
  =============================
  LOGIN
  =============================
  */
  Future<void> login(
    String identifier,
    String password,
  ) async {
    _state = _state.copyWith(
      isLoading: true,
      error: null,
    );

    notifyListeners();

    try {
      /* 🔥 KLJUČNO – OBRIŠI STARI TOKEN */
await _storage.clearAll();

      final res = await _api.post(
        "auth/login_mobile.php",
        body: {
          "identifier": identifier,
          "password": password,
        },
      );

      if (res["success"] != true) {
        throw Exception("LOGIN_FAILED");
      }

      final token = res["token"];

      if (token == null || token.toString().isEmpty) {
        throw Exception("TOKEN_MISSING");
      }

      /* 🔥 SPREMI NOVI TOKEN */
      await _storage.saveToken(token);

      /* 🔥 SET CONTACT ID */
      _contactId = res["contact_id"]?.toString();

      debugPrint("LOGIN TOKEN: $token");
      debugPrint("LOGIN CONTACT_ID: $_contactId");

      _state = _state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );

      notifyListeners();

    } catch (e) {
      debugPrint("LOGIN ERROR: $e");

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );

      notifyListeners();
    }
  }

  /*
  =============================
  LOGOUT
  =============================
  */
  Future<void> logout() async {
await _storage.clearAll();

    _contactId = null;

    _state = const AuthState();

    notifyListeners();
  }
}