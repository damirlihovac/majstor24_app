import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:majstor24_app/core/auth/auth_session.dart';

class PaymentSelectionModal extends StatefulWidget {
  final String trx;
  final double amount;
  final VoidCallback onSuccess;

  const PaymentSelectionModal({
    super.key,
    required this.trx,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<PaymentSelectionModal> createState() =>
      _PaymentSelectionModalState();
}

class _PaymentSelectionModalState
    extends State<PaymentSelectionModal> {

  String? _paymentMethod;
  String? _selectedCard;

  bool _loading = false;

  List<Map<String, dynamic>> _cards = [];

  Future<void> _loadCards() async {

    final token = AuthSession.token;
    if (token == null) return;

    final res = await http.get(
      Uri.parse(
        "https://majstor24.ba/api/payment/get_register_cards_mobile.php",
      ),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(res.body);

    if (data["success"] == true) {
      setState(() {
        _cards =
            List<Map<String, dynamic>>.from(data["cards"]);
      });
    }
  }

  Future<void> _startCardPayment() async {

    final token = AuthSession.token;
    if (token == null) return;

    setState(() => _loading = true);

    try {

      final res = await http.post(
        Uri.parse(
          "https://majstor24.ba/api/payment/start_ticket_mobile.php",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "merchant_trx_id": widget.trx,
          "card_id": _selectedCard,
          "amount": widget.amount,
          "currency": "BAM"
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] != true) {
        throw Exception(
          data["message"] ?? "Ne mogu pokrenuti plaćanje",
        );
      }

      final redirectUrl = data["redirectUrl"];

      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception("redirectUrl nedostaje");
      }

      if (!mounted) return;

      Navigator.pop(context);

      widget.onSuccess();

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

  Future<void> _cashOrVirman(String method) async {

    final token = AuthSession.token;
    if (token == null) return;

    setState(() => _loading = true);

    try {

      final res = await http.post(
        Uri.parse(
          "https://majstor24.ba/api/ticket/sync_request.php",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "trx": widget.trx,
          "method": method,
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] != true) {
        throw Exception(
          data["message"] ?? "Greška kreiranja ticketa",
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      widget.onSuccess();

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

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Način plaćanja",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          RadioListTile<String>(
            value: "kartica",
            groupValue: _paymentMethod,
            title: const Text("Kartica"),
            onChanged: (val) async {

              setState(() {
                _paymentMethod = val;
              });

              await _loadCards();

            },
          ),

          RadioListTile<String>(
            value: "ziralno",
            groupValue: _paymentMethod,
            title: const Text("Žiralno"),
            onChanged: (val) {

              setState(() {
                _paymentMethod = val;
              });

            },
          ),

          RadioListTile<String>(
            value: "gotovina",
            groupValue: _paymentMethod,
            title: const Text("Gotovina"),
            onChanged: (val) {

              setState(() {
                _paymentMethod = val;
              });

            },
          ),

          if (_paymentMethod == "kartica")

            Column(
              children: _cards.map((card) {

                return RadioListTile<String>(
                  value: card["id"].toString(),
                  groupValue: _selectedCard,
                  title: Text(
                    "${card["brand"]} ${card["masked"]}"
                  ),
                  onChanged: (val) {
                    setState(() {
                      _selectedCard = val;
                    });
                  },
                );

              }).toList(),
            ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {

                      if (_paymentMethod == "kartica") {

                        if (_selectedCard == null) return;

                        _startCardPayment();

                      } else if (_paymentMethod == "ziralno") {

                        _cashOrVirman("VIRMAN");

                      } else if (_paymentMethod == "gotovina") {

                        _cashOrVirman("CASH");

                      }

                    },
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Nastavi"),
            ),
          ),

          const SizedBox(height: 10),

        ],
      ),
    );
  }
}