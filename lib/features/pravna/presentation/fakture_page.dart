import 'package:flutter/material.dart';

class FakturePage extends StatelessWidget {
  const FakturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fakture"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          Card(
            child: ListTile(
              title: Text(
                "Faktura #1001",
              ),
              subtitle: Text(
                "Iznos: 80 KM",
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
          ),

          SizedBox(height:12),

          Card(
            child: ListTile(
              title: Text(
                "Faktura #1002",
              ),
              subtitle: Text(
                "Iznos: 50 KM",
              ),
              trailing: Icon(
                Icons.chevron_right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}