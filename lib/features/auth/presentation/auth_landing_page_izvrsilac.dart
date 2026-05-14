import 'package:flutter/material.dart';
import 'role_selection_page.dart';


class AuthLandingPageIzvrsilac extends StatelessWidget {
  const AuthLandingPageIzvrsilac({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Izvršilac")),
      body: const Center(
        child: Text("Login / Registracija - Izvršilac"),
      ),
    );
  }
}