import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'unos_paketa_modal.dart';
import '../../payment/presentation/payment_card_modal.dart';

class KupipaketPage extends StatefulWidget {
  const KupipaketPage({super.key});

  @override
  State<KupipaketPage> createState() => _KupipaketPageState();
}

class _KupipaketPageState extends State<KupipaketPage> {
  final ApiClient _api = ApiClient();

  final List<Map<String, dynamic>> _paketi = [
    {"id": 51, "naziv": "Sigurica", "opis": "Bazni paket asistencija", "cijena": 48.00},
    {"id": 52, "naziv": "DoMax", "opis": "Plus paket asistencija", "cijena": 144.00},
    {"id": 53, "naziv": "PreDoMium", "opis": "Premium usluge", "cijena": 240.00},
  ];

  final List<Map<String, dynamic>> _korpa = [];

  double get _ukupno =>
      _korpa.fold(0.0, (sum, item) => sum + (item['cijena'] as double));

  Future<void> _dodajUKorpu(Map<String, dynamic> paket) async {
    final item = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UnosPaketaModal(paket: paket),
    );

    if (item != null) {
      setState(() => _korpa.add(item));
    }
  }

  /* ========================================
     UNIFIED PAYMENT (ISTO KAO TICKET)
  ======================================== */

  Future<void> _idiNaPlacanje() async {
    if (_korpa.isEmpty) return;

    final trx = "PKG-${DateTime.now().millisecondsSinceEpoch}";

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PaymentCardModal(
        trx: trx,
        type: "package",
        amount: _ukupno,
        packages: _korpa,
      ),
    );

    if (result == "success") {
      setState(() => _korpa.clear());
    }
  }

  /* ========================================
     UI
  ======================================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pregled paketa i kupovina"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paketi.length,
        itemBuilder: (context, index) {
          final paket = _paketi[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paket['naziv'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(paket['opis']),
                  const SizedBox(height: 10),
                  Text(
                    "${paket['cijena']} KM",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _dodajUKorpu(paket),
                    child: const Text("Dodaj u korpu"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _idiNaPlacanje,
          child: Text("Idi na plaćanje (${_korpa.length})"),
        ),
      ),
    );
  }
}