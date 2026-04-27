import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:majstor24_app/features/home/presentation/home_page.dart';
import 'package:majstor24_app/features/payment/presentation/payment_webview_modal.dart';
import 'package:majstor24_app/main.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/payment/presentation/payment_card_modal.dart';
import 'package:majstor24_app/features/ticket/presentation/request_success_page.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestConfirmationPage extends StatefulWidget {
  final String trx;

  const RequestConfirmationPage({
    super.key,
    required this.trx,
  });

  @override
  State<RequestConfirmationPage> createState() =>
      _RequestConfirmationPageState();
}

class _RequestConfirmationPageState extends State<RequestConfirmationPage> {
  final ApiClient _api = ApiClient();

  bool _loading = true;
  bool _paying = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadConfirmation();
  }


  /* ==========================================
     LOAD CONFIRMATION DATA
  ========================================== */

  Future<void> _loadConfirmation() async {
    try {
      final res = await _api.get(
        "ticket/get_confirmation.php?trx=${widget.trx}",
      );

      if (!mounted) return;

      if (res["success"] == true) {
        setState(() {
          _data = res["data"];
        });
      } else {
        throw Exception(res["message"] ?? "Greška potvrde");
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /* ==========================================
     PAY WITH CARD
  ========================================== */

  Future<void> _payCard() async {
    if (_paying) return;

    setState(() => _paying = true);

    try {
      final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PaymentCardModal(
          trx: widget.trx,
        ),
      );

      if (!mounted) return;

      if (result == "success") {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RequestSuccessPage(trx: widget.trx),
          ),
          (route) => false,
        );
        return;
      }

      if (result == "refresh") {
        setState(() => _paying = false);
        return;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  /* ==========================================
     CASH / VIRMAN
  ========================================== */

  Future<void> _payCashOrVirman(String method) async {
    if (_paying) return;

    setState(() => _paying = true);

    try {
      final res = await _api.post(
        "payment/start_ticket_mobile.php",
        body: {
          "merchant_trx_id": widget.trx,
          "method": method,
        },
      );

      if (res["success"] != true) {
        throw Exception(res["message"] ?? "Greška kreiranja ticketa");
      }

      if (res["status"] != "DONE") {
        throw Exception("Ticket nije kreiran");
      }

      if (!mounted) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RequestSuccessPage(trx: widget.trx),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }

  /* ==========================================
     CLANSKI BONITET (DODANO)
  ========================================== */

  Future<void> _openClanskiModal() async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Unesite broj članskog seta",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "npr. CL-12345",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final broj = controller.text.trim();

                    if (broj.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Unesite broj")),
                      );
                      return;
                    }

                    try {
final raw = await _api.post(
  "validate_clanski_mobile.php",
  body: {
    "broj": broj,
  },
);

print("CLANSKI RAW: $raw");

final res = raw is String ? jsonDecode(raw) : raw;

                      if (res["success"] == true) {
                        Navigator.pop(context);
                        _payWithClanski(broj);
                      } else {
                        throw Exception(res["message"]);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Greška: $e")),
                      );
                    }
                  },
                  child: const Text("Potvrdi"),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Odustani"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _payWithClanski(String broj) async {
    if (_paying) return;

    setState(() => _paying = true);

    try {
      final res = await _api.post(
        "payment/start_ticket_mobile.php",
        body: {
          "merchant_trx_id": widget.trx,
          "method": "CLANSKI",
          "clanski_broj": broj,
        },
      );

      if (res["success"] != true) {
        throw Exception(res["message"] ?? "Greška");
      }

      if (!mounted) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RequestSuccessPage(trx: widget.trx),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _paying = false);
      }
    }
  }
/* ==========================================
   UI
========================================== */

@override
Widget build(BuildContext context) {
  final d = _data;

  return Scaffold(
    appBar: AppBar(
      title: const Text("Potvrda zahtjeva"),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : (d == null)
            ? const Center(child: Text("Nema podataka."))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /* ======================================
                       🔥 REZIME ZAHTJEVA
                    ====================================== */
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Rezime zahtjeva",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context); // 🔥 nazad na formu
                                },
                                child: const Text(
                                  "Uredi",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 12),

                          _buildRow("Usluga", d["request"]?["usluga"] ?? "-"),
                          _buildRow("Podgrupa", d["request"]?["podgrupa"] ?? "-"),
                          _buildRow("Adresa", d["request"]?["adresa"] ?? "-"),
                          _buildRow("Grad", d["request"]?["mjesto"] ?? "-"),

                          _buildRow("Datum", d["termin"]?["datum"] ?? "-"),
                          _buildRow("Vrijeme", d["termin"]?["vrijeme"] ?? "-"),

                          _buildRow("Napomena", d["request"]?["napomene"] ?? "-"),
                          _buildRow(
                            "Cijena",
                            "${d["request"]?["cijena"] ?? 0} BAM",
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      "Način plaćanja",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _paying ? null : _payCard,
                        child: const Text("Kartično"),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _paying
                            ? null
                            : () => _payCashOrVirman("CASH"),
                        child: const Text("Gotovina"),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _paying
                            ? null
                            : () => _payCashOrVirman("VIRMAN"),
                        child: const Text("Žiralno / Virman"),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _paying ? null : _openClanskiModal,
                        child: const Text("Članski bonitet"),
                      ),
                    ),
                  ],
                ),
              ),
  );
  
}
/* ==========================================
   🔥 HELPER
========================================== */

Widget _buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

}