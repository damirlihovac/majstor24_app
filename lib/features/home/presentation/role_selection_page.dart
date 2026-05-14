import 'package:flutter/material.dart';
import '../../../core/role_manager.dart';
import 'auth_gate.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _selectRole(BuildContext context, String role) {
    // ✔ postavi globalni role
    RoleManager.setRole(role);

    // ✔ idi na login flow (AuthGate)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Majstor24"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Kako koristite aplikaciju?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            _roleButton(
              context,
              title: "Fizičko lice",
              icon: Icons.person_outline,
              role: "fizicka",
            ),

            const SizedBox(height: 16),

            _roleButton(
              context,
              title: "Pravno lice",
              icon: Icons.business_outlined,
              role: "pravna",
            ),

            const SizedBox(height: 16),

            _roleButton(
              context,
              title: "Izvršilac",
              icon: Icons.engineering_outlined,
              role: "izvrsilac",
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String role,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () => _selectRole(context, role),
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}