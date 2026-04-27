import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../payment/presentation/payment_webview_modal.dart';
import '../../payment/presentation/payment_success_mobile_page.dart';

class PaymentSelectionPackageModal extends StatefulWidget {
  final List<Map<String, dynamic>> korpa;
  final double ukupno;
  final ApiClient api;
  final VoidCallback onSuccess;

  const PaymentSelectionPackageModal({
    super.key,
    required this.korpa,
    required this.ukupno,
    required this.api,
    required this.onSuccess,
  });

  @override
  State<PaymentSelectionPackageModal> createState() =>
      _PaymentSelectionPackageModalState();
}

class _PaymentSelectionPackageModalState
    extends State<PaymentSelectionPackageModal> {

  String? _paymentMethod;
  int? _selectedCard;
  List<dynamic> _cards = [];
  bool _loading = false;

  /* ================= LOAD CARDS ================= */

  Future<void> _loadCards() async {

    setState(() => _loading = true);

    final res = await widget.api.get(
      "payment/get_register_cards_mobile.php",
    );

    if (res["success"] == true) {
      _cards = res["cards"] ?? [];
    }

    setState(() => _loading = false);
  }

  /* ================= POLLING ================= */

  Future<void> _waitForPayment(String trx) async {

    for (int i = 0; i < 15; i++) {

      await Future.delayed(const Duration(seconds: 2));

      final res = await widget.api.get(
        "payment/check_package_status.php?trx=$trx",
      );

      if (res["status"] == "PAID") {
        return;
      }
    }

    throw Exception("Plaćanje nije potvrđeno");
  }

  /* ================= START PAYMENT ================= */

  Future<void> _startPayment() async {

    try {

      if (_paymentMethod == "kartica" && _selectedCard == null) {
        throw Exception("Odaberite karticu");
      }

      final res = await widget.api.post(
        "payment/start_package_mobile.php",
        body: {
          "paymentid": _selectedCard,
          "amount": widget.ukupno,
          "currency": "BAM",
          "packages": widget.korpa,
        },
      );

      if (res["success"] != true) {
        throw Exception(res["message"] ?? "Greška");
      }

      if (_paymentMethod == "kartica") {

        final redirectUrl = res["redirectUrl"];
        final trx = res["merchant_trx_id"];

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebviewModal(url: redirectUrl),
          ),
        );

        if (result == "success") {

          if (!mounted) return;

          // 🔥 LOADER
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          await _waitForPayment(trx);

          Navigator.pop(context); // loader
          Navigator.pop(context); // modal

          widget.onSuccess();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessMobilePage(
                trx: trx,
                title: "Uspješna kupovina",
                message: "Vaš paket je uspješno kupljen.",
              ),
            ),
          );
        }

      } else {

        widget.onSuccess();
        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text("Način plaćanja"),

          if (_paymentMethod == null) ...[
            ElevatedButton(
              onPressed: () async {
                _paymentMethod = "kartica";
                await _loadCards();
                setState(() {});
              },
              child: const Text("Kartica"),
            ),
          ],

          if (_paymentMethod == "kartica") ...[
            ..._cards.map((c) {
              final id = int.tryParse(c["id"].toString()) ?? 0;
              return RadioListTile<int>(
                value: id,
                groupValue: _selectedCard,
                title: Text("${c["brand"]} ${c["masked"]}"),
                onChanged: (v) => setState(() => _selectedCard = v),
              );
            }),
          ],

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: _startPayment,
            child: const Text("Nastavi"),
          ),
        ],
      ),
    );
  }
}