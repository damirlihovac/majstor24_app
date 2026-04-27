import 'payment_success_page.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../payment/presentation/payment_webview_modal.dart';

class PaymentCardModal extends StatefulWidget {
  final String trx;
  final String type; // ticket | package
  final double? amount;
  final List<dynamic>? packages;

  const PaymentCardModal({
    super.key,
    required this.trx,
    this.type = "ticket",
    this.amount,
    this.packages,
  });

  @override
  State<PaymentCardModal> createState() => _PaymentCardModalState();
}

class _PaymentCardModalState extends State<PaymentCardModal> {
  final ApiClient _api = ApiClient();

  bool _loading = true;
  List<dynamic> cards = [];
  int? selectedCardId;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  /* ========================================
     LOAD CARDS (UNIFIED)
  ======================================== */

  Future<void> _loadCards() async {
    try {
      setState(() => _loading = true);

      final res = await _api.get("payment/get_register_cards_mobile.php");

      if (!mounted) return;

      final rawCards = res["cards"] ?? [];

      // ✅ samo validne kartice (ključ fix)
      final validCards = rawCards.where((c) {
        final reg = c["registrationId"];
        return reg != null && reg.toString().trim().isNotEmpty;
      }).toList();

      setState(() {
        cards = validCards;
        selectedCardId = cards.isNotEmpty ? cards.first["id"] : null;
        _loading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška pri učitavanju kartica")),
      );
    }
  }

  /* ========================================
     REGISTER CARD
  ======================================== */

  Future<void> _registerCard() async {
    try {
      setState(() => _loading = true);

      final res = await _api.post("payment/start_register_mobile.php");

      final redirectUrl = res["redirectUrl"];

      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception("NO_REDIRECT_URL");
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebviewModal(url: redirectUrl),
        ),
      );

      if (!mounted) return;

      if (result == "success") {
        await _loadCards();
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Greška pri registraciji kartice"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /* ========================================
     PAY WITH CARD (UNIFIED)
  ======================================== */

  Future<void> _payWithSelectedCard() async {
    if (selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Odaberite karticu")),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      final card = cards.firstWhere(
        (c) => int.tryParse(c["id"].toString()) == selectedCardId,
        orElse: () => null,
      );

      if (card == null) {
        throw Exception("Kartica nije pronađena");
      }

      final endpoint = widget.type == "package"
          ? "payment/start_package_mobile.php"
          : "payment/start_ticket_mobile.php";

      final body = widget.type == "package"
          ? {
              "paymentid": card["id"],
              "amount": widget.amount,
              "currency": "BAM",
              "packages": widget.packages,
            }
          : {
              "merchant_trx_id": widget.trx,
              "card_id": card["id"],
            };

      print("PAY REQUEST: $body");

      final res = await _api.post(endpoint, body: body);

      final redirectUrl =
          res["redirectUrl"] ?? res["redirect_url"] ?? "";

      if (redirectUrl.isEmpty) {
        throw Exception("NO_REDIRECT_URL");
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebviewModal(url: redirectUrl),
        ),
      );

      if (!mounted) return;

if (result == "success") {
  Navigator.pop(context); // zatvori modal

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentSuccessPage(),
    ),
  );

  return;
}

      if (result == "error") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Greška pri plaćanju"),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (result == "cancel") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Plaćanje otkazano"),
          ),
        );
      }

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Greška pri plaćanju"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /* ========================================
     UI
  ======================================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kartice"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cards.isEmpty
                      ? const Center(
                          child: Text("Nema dostupnih kartica"),
                        )
                      : ListView.builder(
                          itemCount: cards.length,
itemBuilder: (context, index) {
  final card = cards[index];
  final id = card["id"] as int;

  return ListTile(
    leading: const Icon(Icons.credit_card),
    title: Text(
      "${card["brand"] ?? ""} ${card["maskedCard"] ?? ""}",
    ),
    subtitle: Text(
      card["cardHolder"] ?? "",
    ),
    trailing: Radio<int>(
      value: id,
      groupValue: selectedCardId,
      onChanged: (val) {
        setState(() {
          selectedCardId = val;
        });
      },
    ),
  );
},
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: selectedCardId != null
                            ? _payWithSelectedCard
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Plati odabranom karticom"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _registerCard,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Dodaj novu karticu"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}