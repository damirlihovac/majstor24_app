import 'package:flutter/material.dart';
import '../home/home_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _selectRole(BuildContext context, String role) {
    // TODO: kasnije ide shared_preferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Majstor24")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: () => _selectRole(context, "fizicka"),
              child: const Text("Fizičko lice"),
            ),

            ElevatedButton(
              onPressed: () => _selectRole(context, "pravna"),
              child: const Text("Pravno lice"),
            ),

            ElevatedButton(
              onPressed: () => _selectRole(context, "izvrsilac"),
              child: const Text("Izvršilac"),
            ),

          ],
        ),
      ),
    );
  }
}