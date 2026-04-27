import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/auth/presentation/auth_landing_page.dart';

import 'package:majstor24_app/features/home/presentation/home_page.dart';

import 'package:majstor24_app/features/profile/data/models/user_profile.dart';
import 'package:majstor24_app/features/profile/data/profile_remote_datasource.dart';

import 'package:majstor24_app/core/network/api_client.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  bool _loading = true;
  bool _profileLoaded = false;

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {

    final auth = context.read<AuthNotifier>();

    // ako korisnik nije prijavljen
    if (!auth.isLoggedIn) {

      setState(() {
        _loading = false;
      });

      return;
    }

    try {

      final profileDs =
          ProfileRemoteDatasource(_apiClient);

      final data = await profileDs.getProfile();

      if (data.isNotEmpty) {

        context
            .read<UserProfile>()
            .updateFromJson(data);

        _profileLoaded = true;

      }

    } catch (e) {

      debugPrint("PROFILE LOAD ERROR: $e");

    }

    if (mounted) {

      setState(() {
        _loading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthNotifier>();

    if (_loading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    // nije logovan
    if (!auth.isLoggedIn) {

      return const AuthLandingPage();

    }

    // logovan ali profil nije učitan
    if (!_profileLoaded) {

      return const AuthLandingPage();

    }

    // sve OK
    return const HomePage();
  }
}