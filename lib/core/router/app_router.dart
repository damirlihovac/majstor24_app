import 'package:flutter/material.dart';

import 'package:majstor24_app/features/auth/presentation/auth_landing_page.dart';
import 'package:majstor24_app/features/home/presentation/home_page.dart';
import 'package:majstor24_app/features/package/presentation/kupipaket_page.dart';

class AppRouter {

  static const String home = '/home';
  static const String auth = '/auth';
  static const String kupipaket = '/kupipaket';

  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case auth:
        return MaterialPageRoute(
          builder: (_) => const AuthLandingPage(),
        );

      case kupipaket:
        return MaterialPageRoute(
          builder: (_) => const KupipaketPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Route not found"),
            ),
          ),
        );
    }
  }
}