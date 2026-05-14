import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/pravna/application/pravna_notifier.dart';

class AktivniUgovoriPage extends StatefulWidget {
  const AktivniUgovoriPage({super.key});

  @override
  State<AktivniUgovoriPage> createState() => _AktivniUgovoriPageState();
}

class _AktivniUgovoriPageState extends State<AktivniUgovoriPage> {

  final ApiClient _api = ApiClient();

  bool _loading = true;
  List _contracts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {

    try {
      final pravna = context.read<PravnaNotifier>();
      final id = pravna.profile?["account_id"]?.toString();

      final res = await _api.post(
        "get_service_contracts_company.php",
        body: {"account_id": id},
      );

      setState(() {
        _contracts = res["result"] ?? [];
        _loading = false;
      });

    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Widget _item(dynamic c) {
    final item = c as Map;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment),
        title: Text(item["subject"] ?? ""),
        subtitle: Text(
          "Od: ${item["start_date"]}\nDo: ${item["due_date"]}"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Aktivni ugovori")),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contracts.isEmpty
              ? const Center(child: Text("Nema aktivnih ugovora"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _contracts.map((e) => _item(e)).toList(),
                ),
    );
  }
}