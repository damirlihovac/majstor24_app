import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';

class TicketDetailsPage extends StatefulWidget {
  final dynamic ticketId;
  final String ticketNumber;

  const TicketDetailsPage({
    super.key,
    required this.ticketId,
    required this.ticketNumber,
  });

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final ApiClient _api = ApiClient();

  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get(
        "ticket/get_ticket_details.php?id=${widget.ticketId}",
      );

      if (res is Map && res["success"] == true) {
        setState(() {
          _data = res["data"];
          _loading = false;
        });
      } else {
        throw Exception("LOAD_FAILED");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _text(dynamic v) => v?.toString() ?? '';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Tiket ${widget.ticketNumber}"),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : (_data == null)
            ? const Center(child: Text("Nema podataka"))
            : Padding(
                padding: const EdgeInsets.all(16), // 🔥 OVO TI JE FALILO
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // NASLOV
                      Text(
                        _text(_data!['title']),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // STATUS
                      Text("Status: ${_text(_data!['status'])}"),
                      Text("Prioritet: ${_text(_data!['priority'])}"),

                      const SizedBox(height: 12),

                      // NOVI PODACI
                      Text("Usluga: ${_text(_data!['usluga'])}"),
                      Text("Kategorija: ${_text(_data!['category'])}"),

                      const SizedBox(height: 10),

                      Text("Datum: ${_text(_data!['datum'])} ${_text(_data!['vrijeme'])}"),

                      const SizedBox(height: 10),

                      Text("Cijena: ${_text(_data!['cijena'])} KM"),
                      Text("Način plaćanja: ${_text(_data!['placanje'])}"),

                      const SizedBox(height: 16),

                      // NAPOMENA
                      if (_text(_data!['napomena']).isNotEmpty) ...[
                        const Text(
                          "Napomena:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(_text(_data!['napomena'])),
                        const SizedBox(height: 16),
                      ],

                      // RJEŠENJE
                      if (_text(_data!['solution']).isNotEmpty) ...[
                        const Text(
                          "Rješenje:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(_text(_data!['solution'])),
                      ],
                    ],
                  ),
                ),
              ),
  );
}
}