import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import 'package:majstor24_app/features/payment/presentation/bankart_webview.dart';

class ProfileCardsSection extends StatefulWidget {
  const ProfileCardsSection({super.key});

  @override
  State<ProfileCardsSection> createState() =>
      _ProfileCardsSectionState();
}

class _ProfileCardsSectionState
    extends State<ProfileCardsSection> {

  final ApiClient _api = ApiClient();

  bool isLoading = true;
  bool isRegistering = false;

  List<dynamic> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // ================= LOAD CARDS =================

  Future<void> _loadCards() async {

    setState(() => isLoading = true);

    try {

      final data =
          await _api.get('get_register_cards_mobile.php');

      if (data['success'] == true) {
        cards = data['cards'] ?? [];
      } else {
        cards = [];
      }

    } catch (_) {
      cards = [];
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ================= REGISTER CARD =================

  Future<void> _registerNewCard() async {

    if (isRegistering) return;

    setState(() => isRegistering = true);

    try {

      final data = await _api.post(
        'payment/start_register_mobile.php',
        body: {},
      );

      if (data['success'] == true &&
          data['redirectUrl'] != null) {

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BankartWebView(url: data['redirectUrl']),
          ),
        );

        await _loadCards();

      } else {

        _showError(
            data['message'] ?? "Greška pri registraciji.");

      }

    } catch (e) {

      _showError(e.toString());

    }

    if (mounted) {
      setState(() => isRegistering = false);
    }
  }

  // ================= DEACTIVATE CARD =================

  Future<void> _deactivateCard(String cardId) async {

    final confirm = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text("Deaktivacija kartice"),

        content: const Text(
            "Da li ste sigurni da želite deaktivirati ovu karticu?"),

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Odustani"),
          ),

          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text(
              "Deaktiviraj",
              style: TextStyle(color: Colors.red),
            ),
          ),

        ],
      ),
    );

    if (confirm != true) return;

    try {

      final data = await _api.post(
        'payment/deregister_mobile.php',
        body: {'paymentid': cardId},
      );

      if (data['success'] == true) {

        await _loadCards();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Kartica uspješno deaktivirana"),
          ),
        );

      } else {

        _showError(data['message'] ?? "Greška.");

      }

    } catch (_) {

      _showError("Server error");

    }
  }

  void _showError(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Center(
          child: CircularProgressIndicator());

    }

    return Column(
      children: [

        ElevatedButton(

          onPressed:
              isRegistering ? null : _registerNewCard,

          child: isRegistering
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Registruj novu karticu"),

        ),

        const SizedBox(height: 20),

        Expanded(

          child: cards.isEmpty
              ? const Center(
                  child: Text(
                      "Nemate registrovanih kartica."),
                )

              : ListView.builder(

                  itemCount: cards.length,

                  itemBuilder: (context, index) {

                    final card = cards[index];

                    return Card(

                      child: ListTile(

                        leading: const Icon(Icons.credit_card),

                        title: Text(
                          card['maskedCard'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Brand: ${card['brand'] ?? ''}"),
                            Text("Vlasnik: ${card['cardHolder'] ?? ''}"),
                          ],
                        ),

                        trailing: TextButton(
                          onPressed: () =>
                              _deactivateCard(
                                  card['id'].toString()),
                          child: const Text(
                            "Deaktiviraj",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                      ),
                    );
                  },
                ),
        )

      ],
    );
  }
}