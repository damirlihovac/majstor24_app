import 'dart:io';

import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/pravna/presentation/payment_webview_page.dart';
import 'package:majstor24_app/features/pravna/presentation/ticket_success_page.dart';

class TicketConfirmationPage extends StatefulWidget {

  final dynamic profile;
  final String? selectedGroup;
  final String? selectedSubgroup;
  final int? selectedPrice;
  final String naslov;
  final String address;
  final String zip;
  final String city;
  final DateTime? selectedDate;
  final String? selectedHour;
  final String? selectedMinute;
  final bool urgent;
  final bool callMe;

  final String? paymentMethod;
  final File? selectedImage;

  const TicketConfirmationPage({
    super.key,
    required this.profile,
    required this.selectedGroup,
    required this.selectedSubgroup,
    required this.selectedPrice,
    required this.naslov,
    required this.address,
    required this.zip,
    required this.city,
    required this.selectedDate,
    required this.selectedHour,
    required this.selectedMinute,
    required this.urgent,
    required this.callMe,

    this.paymentMethod,
    this.selectedImage,
  });

  @override
  State<TicketConfirmationPage> createState() =>
      _TicketConfirmationPageState();
}

class _TicketConfirmationPageState
    extends State<TicketConfirmationPage> {

  final ApiClient api = ApiClient();

  bool loading = false;

  List<dynamic> cards = [];

  String? paymentMethod;

  int? selectedCardId;

  final contractController =
      TextEditingController();

  @override
  void initState() {

    super.initState();
	 paymentMethod = widget.paymentMethod;

    loadCards();
  }

  Future<void> loadCards() async {

  try {

    debugPrint("UCITAVAM KARTICE...");

    final res = await api.get(
      'get_registered_cards_pravna_mobile.php',
    );

    debugPrint("CARDS RESPONSE: $res");

    if (res['success'] == true) {

      setState(() {

        cards = res['cards'] ?? [];

      });

      debugPrint("UCITANE KARTICE: $cards");

    } else {

      debugPrint(
        "API SUCCESS FALSE: ${res['message']}",
      );
    }

  } catch (e) {

    debugPrint(
      "GRESKA LOAD CARDS: $e",
    );
  }
}

  Future<void> submit() async {

    final messenger =
        ScaffoldMessenger.of(context);

    if (paymentMethod == null) {

      messenger.showSnackBar(

        const SnackBar(
          content: Text(
            'Odaberite način plaćanja',
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      if (paymentMethod == 'karticno') {

        if (selectedCardId == null) {

          messenger.showSnackBar(

            const SnackBar(
              content: Text(
                'Odaberite karticu',
              ),
            ),
          );

          setState(() {
            loading = false;
          });

          return;
        }

final trxId =
    DateTime.now()
        .millisecondsSinceEpoch
        .toString();

final startRes =
    await api.postAbsolute(

  "https://www.majstor24.ba/pravna/placanje/start_transaction_saved_ticket.php",

  body: {

    'bankart_ws_id':
        selectedCardId,

    'amount':
        widget.urgent
            ? ((widget.selectedPrice ?? 0) * 2)
            : (widget.selectedPrice ?? 0),

    'currency': 'BAM',

    'merchant_trx_id':
        trxId,

    'group_service':
        widget.selectedGroup ?? '',

    'sub_service':
        widget.selectedSubgroup ?? '',

    'description':
        widget.naslov,

    'address':
        widget.address,

    'zip':
        widget.zip,

    'city':
        widget.city,
  },
);


        if (startRes['success'] != true) {

          messenger.showSnackBar(

            SnackBar(
              content: Text(
                startRes['message'] ??
                    'Greška pokretanja plaćanja',
              ),
            ),
          );

          setState(() {
            loading = false;
          });

          return;
        }

        final redirectUrl =
            startRes['redirect']
                ?.toString() ??
            '';

        final success =
            await Navigator.push<bool>(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        PaymentWebviewPage(
                      paymentUrl:
                          redirectUrl,
                    ),
                  ),
                ) ??
                false;

        if (!success) {

          setState(() {
            loading = false;
          });

          return;
        }

        final res =
            await api.post(

          'create_ticket_pravna_flutter.php',

          body: {

            'account_id':
                widget.profile['account_id'] ?? '',

            'group_service':
                widget.selectedGroup ?? '',

            'sub_service':
                widget.selectedSubgroup ?? '',

            'price':
                widget.urgent
                    ? ((widget.selectedPrice ?? 0) * 2)
                        .toString()
                    : (widget.selectedPrice ?? 0)
                        .toString(),

            'description':
                widget.naslov,

            'address':
                widget.address,

            'zip':
                widget.zip,

            'city':
                widget.city,

            'datum_intervencije':
                widget.selectedDate != null
                    ? '${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}'
                    : '',

            'vrijeme_intervencije':
                widget.selectedHour != null &&
                        widget.selectedMinute != null
                    ? '${widget.selectedHour}:${widget.selectedMinute}'
                    : '',

            'poziv_majstora':
                widget.callMe ? '1' : '0',

            'hitna_intervencija':
                widget.urgent ? '1' : '0',

            'payment_method':
                'karticno',

            'payment_status':
                'paid',

            'bankart_transaction_id':
                trxId,
          },
        );

        if (res['success'] == true) {

          if (!mounted) {
            return;
          }

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const TicketSuccessPage(),
            ),
          );

        } else {

          messenger.showSnackBar(

            SnackBar(
              content: Text(
                res['msg'] ??
                    'Greška kreiranja zahtjeva',
              ),
            ),
          );
        }

      } else {

        final res =
            await api.post(

          'create_ticket_pravna_flutter.php',

          body: {

            'account_id':
                widget.profile['account_id'] ?? '',

            'group_service':
                widget.selectedGroup ?? '',

            'sub_service':
                widget.selectedSubgroup ?? '',

            'price':
                widget.urgent
                    ? ((widget.selectedPrice ?? 0) * 2)
                        .toString()
                    : (widget.selectedPrice ?? 0)
                        .toString(),

            'description':
                widget.naslov,

            'address':
                widget.address,

            'zip':
                widget.zip,

            'city':
                widget.city,

            'datum_intervencije':
                widget.selectedDate != null
                    ? '${widget.selectedDate!.year}-${widget.selectedDate!.month.toString().padLeft(2, '0')}-${widget.selectedDate!.day.toString().padLeft(2, '0')}'
                    : '',

            'vrijeme_intervencije':
                widget.selectedHour != null &&
                        widget.selectedMinute != null
                    ? '${widget.selectedHour}:${widget.selectedMinute}'
                    : '',

            'poziv_majstora':
                widget.callMe ? '1' : '0',

            'hitna_intervencija':
                widget.urgent ? '1' : '0',

            'payment_method':
                paymentMethod,

            'contract_number':
                contractController.text.trim(),

            'payment_status':
                paymentMethod == 'gotovina'
                    ? 'pending'
                    : 'paid',
          },
        );

        if (res['success'] == true) {

          if (!mounted) {
            return;
          }

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const TicketSuccessPage(),
            ),
          );

        } else {

          messenger.showSnackBar(

            SnackBar(
              content: Text(
                res['msg'] ??
                    'Greška kreiranja zahtjeva',
              ),
            ),
          );
        }
      }

    } catch (e) {

      messenger.showSnackBar(

        SnackBar(
          content: Text(
            'Greška: $e',
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Potvrda zahtjeva',
        ),
        backgroundColor: Colors.red,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Način plaćanja',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            RadioListTile<String>(
              value: 'karticno',
              groupValue: paymentMethod,
              onChanged: (v) {
                setState(() {
                  paymentMethod = v;
                });
              },
              title: const Text('Kartično'),
            ),

            if (paymentMethod ==
                'karticno')

              Column(
                children:
                    cards.map((card) {

                  return RadioListTile<int>(

                    value:
                        card['paymentid'],

                    groupValue:
                        selectedCardId,

                    onChanged: (v) {

                      setState(() {
                        selectedCardId = v;
                      });
                    },

                    title: Text(
                      '${card['maskedpan']} (${card['cardholder']})',
                    ),
                  );

                }).toList(),
              ),

            RadioListTile<String>(
              value: 'gotovina',
              groupValue: paymentMethod,
              onChanged: (v) {
                setState(() {
                  paymentMethod = v;
                });
              },
              title: const Text('Gotovina'),
            ),

RadioListTile<String>(
  value: 'ziralno',
  groupValue: paymentMethod,
  onChanged: (v) {
    setState(() {
      paymentMethod = v;
    });
  },
  title: const Text('Žiralno'),
),

RadioListTile<String>(
  value: 'ugovorom',
  groupValue: paymentMethod,
  onChanged: (v) {
    setState(() {
      paymentMethod = v;
    });
  },
  title: const Text('Ugovorom'),
),

if (
    paymentMethod ==
        'ugovorom'
)

  TextField(
    controller:
        contractController,

    decoration:
        const InputDecoration(
      labelText:
          'Broj ugovora',
    ),
  ),

            const SizedBox(height: 25),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),

                onPressed:
                    loading
                        ? null
                        : submit,

                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Potvrdi zahtjev',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
