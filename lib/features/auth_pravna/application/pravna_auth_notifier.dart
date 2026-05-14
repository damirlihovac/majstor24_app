import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';

class PravnaAuthState {

  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const PravnaAuthState({

    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  PravnaAuthState copyWith({

    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {

    return PravnaAuthState(

      isLoading:
          isLoading ?? this.isLoading,

      isAuthenticated:
          isAuthenticated ??
              this.isAuthenticated,

      error: error,
    );
  }
}

class PravnaAuthNotifier
    extends ChangeNotifier {

  final ApiClient api =
      ApiClient();

  PravnaAuthState _state =
      const PravnaAuthState();

  PravnaAuthState get state =>
      _state;

  Map<String, dynamic>? profile;

  String? accountId;

  Future<void> login(
    String idbroj,
    String sifra,
  ) async {

    _state = _state.copyWith(
      isLoading: true,
      error: null,
    );

    notifyListeners();

    try {

      final res = await api.post(

        'login_pravno.php',

        body: {

          'idbroj': idbroj,
          'sifra': sifra,
        },
      );

      debugPrint(
        "PRAVNA LOGIN RESPONSE: $res",
      );

      if (res['success'] != true) {

        throw Exception(
          res['message'] ??
              'LOGIN_FAILED',
        );
      }

      profile = res;

      accountId =
          res['account_id']
              ?.toString();

      _state = _state.copyWith(

        isLoading: false,

        isAuthenticated: true,
      );

      notifyListeners();

    } catch (e) {

      debugPrint(
        "PRAVNA LOGIN ERROR: $e",
      );

      _state = _state.copyWith(

        isLoading: false,

        isAuthenticated: false,

        error: e.toString(),
      );

      notifyListeners();
    }
  }

  void logout() {

    profile = null;

    accountId = null;

    _state =
        const PravnaAuthState();

    notifyListeners();
  }
}