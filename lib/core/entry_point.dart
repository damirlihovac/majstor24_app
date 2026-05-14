import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/presentation/role_selection_page.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../core/role_manager.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {

  bool isLoading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();

  final savedRole = null;

    // 🔥 učitaj u RoleManager
    if (savedRole != null) {
      RoleManager.setRole(savedRole);
      print("LOADED ROLE: $savedRole");
    }

    setState(() {
      role = savedRole;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ nema role → idi na izbor
    if (role == null) {
      return const RoleSelectionPage();
    }

    // ✅ ima role → idi dalje
    return AuthGate(); // ❌ bez const
  }
}