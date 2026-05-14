import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/pravna/presentation/ticket_success_page.dart';

class ZiralnoPaymentPage extends StatefulWidget {

  final Map<String, dynamic> ticketData;

  const ZiralnoPaymentPage({
    super.key,
    required this.ticketData,
  });

  @override
  State<ZiralnoPaymentPage> createState() =>
      _ZiralnoPaymentPageState();
}

class _ZiralnoPaymentPageState
    extends State<ZiralnoPaymentPage> {

  final ApiClient api =
      ApiClient();

  bool loading = false;

  /*
  ==========================================
  OTVORI PDF UPLATNICU
  ==========================================
  */

  Future<void> openUplatnica() async {

    try {

      final nazivFirme =
          widget.ticketData['company_name']
              ?.toString() ??
          '';

      final idBroj =
          widget.ticketData['company_id']
              ?.toString() ??
          '';

      final pdvBroj =
          widget.ticketData['pdv']
              ?.toString() ??
          '';

      final adresa =
          widget.ticketData['address']
              ?.toString() ??
          '';

      final ptt =
          widget.ticketData['zip']
              ?.toString() ??
          '';

      final mjesto =
          widget.ticketData['city']
              ?.toString() ??
          '';

      final usluga =
          widget.ticketData['sub_service']
              ?.toString() ??
          '';

      final cijena =
          widget.ticketData['price']
              ?.toString() ??
          '0';

      final url = Uri.parse(

        "https://www.majstor24.ba/pravna/api/posaljiUplatnicupravna.php"
        "?preview=1"
        "&nazivfirme=${Uri.encodeComponent(nazivFirme)}"
        "&idbroj=${Uri.encodeComponent(idBroj)}"
        "&pdvbroj=${Uri.encodeComponent(pdvBroj)}"
        "&adresaobjekta=${Uri.encodeComponent(adresa)}"
        "&ptt=${Uri.encodeComponent(ptt)}"
        "&mjesto=${Uri.encodeComponent(mjesto)}"
        "&usluga=${Uri.encodeComponent(usluga)}"
        "&cijena=${Uri.encodeComponent(cijena)}",
      );

      debugPrint(
        "UPLATNICA URL: $url",
      );

      await launchUrl(
        url,
        mode:
            LaunchMode.externalApplication,
      );

    } catch (e) {

      debugPrint(
        "OPEN PDF ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "Greška otvaranja PDF-a: $e",
          ),
        ),
      );
    }
  }

  /*
  ==========================================
  POŠALJI UPLATNICU + KREIRAJ CRM
  ==========================================
  */

  Future<void> sendUplatnica() async {

    try {

      setState(() {
        loading = true;
      });

      final body = {

        "nazivfirme":
            widget.ticketData['company_name'],

        "idbroj":
            widget.ticketData['company_id'],

        "pdvbroj":
            widget.ticketData['pdv'],

        "email":
            widget.ticketData['email'],

        "adresaobjekta":
            widget.ticketData['address'],

        "ptt":
            widget.ticketData['zip'],

        "mjesto":
            widget.ticketData['city'],

        "usluga":
            widget.ticketData['sub_service'],

        "cijena":
            widget.ticketData['price'],
      };

      debugPrint(
        "SEND UPLATNICA BODY: $body",
      );

      /*
      ==========================
      EMAIL + PDF
      ==========================
      */

      final res = await api.post(

        "posaljiUplatnicupravna.php",

        body: body,
      );

      debugPrint(
        "UPLATNICA RESPONSE: $res",
      );

      if (res['success'] != true) {

        throw Exception(
          res['message'] ??
              'GREŠKA SLANJA UPLATNICE',
        );
      }

      /*
      ==========================
      CREATE CRM TICKET
      ==========================
      */

      final ticketRes =
          await api.post(

        "create_ticket_pravna_flutter.php",

        body: {

          ...widget.ticketData,

          "payment_method":
              "ziralno",

          "payment_status":
              "pending",
        },
      );

      debugPrint(
        "CRM RESPONSE: $ticketRes",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      if (
          ticketRes['success'] ==
              true
      ) {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
                const TicketSuccessPage(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              ticketRes['message'] ??
                  'CRM greška',
            ),
          ),
        );
      }

    } catch (e) {

      debugPrint(
        "ZIRALNO ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "Greška: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Žiralno plaćanje",
        ),
      ),

      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),

          child: ConstrainedBox(

            constraints:
                const BoxConstraints(
              maxWidth: 500,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                const Icon(

                  Icons.receipt_long,

                  size: 90,

                  color: Colors.blue,
                ),

                const SizedBox(height: 24),

                const Text(

                  "Žiralno plaćanje",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(

                  "Pregledajte i pošaljite uplatnicu. Nakon toga zahtjev će biti kreiran u CRM sistemu.",

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(

                  height: 56,

                  child: ElevatedButton.icon(

                    onPressed:
                        openUplatnica,

                    icon: const Icon(
                      Icons.picture_as_pdf,
                    ),

                    label: const Text(
                      "Pogledaj uplatnicu",
                    ),

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.blue,

                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(

                  height: 56,

                  child: ElevatedButton.icon(

                    onPressed:
                        loading
                            ? null
                            : sendUplatnica,

                    icon: loading

                        ? const SizedBox(

                            width: 22,
                            height: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )

                        : const Icon(
                            Icons.send,
                          ),

                    label: Text(

                      loading
                          ? "Slanje..."
                          : "Pošalji uplatnicu",
                    ),

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.green,

                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Container(

                  padding:
                      const EdgeInsets.all(18),

                  decoration: BoxDecoration(

                    color:
                        Colors.grey.shade100,

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(

                        "Podaci zahtjeva",

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "Usluga: ${widget.ticketData['group_service']}",
                      ),

                      Text(
                        "Podusluga: ${widget.ticketData['sub_service']}",
                      ),

                      Text(
                        "Cijena: ${widget.ticketData['price']} KM",
                      ),

                      Text(
                        "Adresa: ${widget.ticketData['address']}",
                      ),

                      Text(
                        "Grad: ${widget.ticketData['city']}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}