import 'package:flutter/material.dart';

class IzvrsilacHome extends StatelessWidget {
  const IzvrsilacHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Izvršilac")),
      body: const Center(child: Text("Dashboard - izvršilac")),
    );
  }
}