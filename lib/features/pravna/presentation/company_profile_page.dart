import 'package:flutter/material.dart';
import 'payment_webview_page.dart';
import 'package:provider/provider.dart';

import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/pravna/application/pravna_notifier.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() =>
      _CompanyProfilePageState();
}

class _CompanyProfilePageState
    extends State<CompanyProfilePage> {

  final ApiClient _api = ApiClient();

  bool _loading = true;
  String? _error;

  Map<String, dynamic> _company = {};

  List _contracts = [];
  List _orders = [];
  List _tickets = [];
  List _invoices = [];
  List _cards = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {

    setState(() {
      _loading = true;
      _error = null;
    });

    try {

      final pravna =
          context.read<PravnaNotifier>();

      final rawId =
          pravna.profile?["account_id"] ??
          pravna.profile?["accountid"];

      if (rawId == null ||
          rawId.toString().isEmpty) {
        throw Exception(
          "ACCOUNT ID NIJE PRONAĐEN"
        );
      }

      final accountId =
          rawId.toString();

      debugPrint(
        "ACCOUNT ID: $accountId"
      );

/*
=========================================
TICKETS
=========================================
*/

final ticketsRes =
    await _api.post(
  "get_company_tickets.php",
  body: {
    "contact_id": accountId,
  },
);

      /*
      =========================================
      COMPANY PROFILE
      =========================================
      */

      final profileRes = await _api.post(
        "get_company_profile.php",
        body: {
          "accountid": accountId,
        },
      );

      debugPrint(
        "PROFILE RES: $profileRes"
      );

      if (profileRes["success"] == true) {

        _company =
            profileRes["data"] ?? {};

      } else {

        throw Exception(
          "Greška učitavanja firme"
        );
      }

      /*
      =========================================
      UGOVORI
      =========================================
      */

      final contractsRes =
          await _api.post(
        "get_service_contracts_company.php",
        body: {
          "account_id": accountId,
        },
      );

      /*
      =========================================
      NARUDŽBE
      =========================================
      */

      final ordersRes =
          await _api.post(
        "get_salesorders_pravna.php",
        body: {
          "contact_id": accountId,
        },
      );

/*
=========================================
KARTICE
=========================================
*/

final cardsRes =
    await _api.get(
  "get_registered_cards_pravna_mobile.php",
);
      /*
      =========================================
      FAKTURE
      =========================================
      */

      final invoicesRes =
          await _api.post(
        "get_invoices_company.php",
        body: {
          "account_id": accountId,
        },
      );

      debugPrint(
        "CONTRACTS RES: $contractsRes"
      );

      debugPrint(
        "ORDERS RES: $ordersRes"
      );
	  
	  debugPrint(
  "CARDS RES: $cardsRes"
);

      debugPrint(
        "INVOICES RES: $invoicesRes"
      );

      setState(() {

        _contracts =
            contractsRes["data"] ??
            contractsRes["result"] ??
            [];

        _orders =
            ordersRes["data"] ??
            ordersRes["result"] ??
            [];
			
			_tickets =
    ticketsRes["tickets"] ??
    ticketsRes["result"] ??
    [];
	
	_cards =
    cardsRes["cards"] ??
    [];


        _invoices =
            invoicesRes["data"] ??
            invoicesRes["result"] ??
            [];

      });

    } catch (e) {

      debugPrint(
        "COMPANY PROFILE ERROR: $e"
      );

      setState(() {
        _error = e.toString();
      });

    }

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await context
        .read<AuthNotifier>()
        .logout();
  }
  Future<void> _registerCard() async {

  bool loaderOpened = false;

  try {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    loaderOpened = true;

final pravna =
    context.read<PravnaNotifier>();

final accountId =
    pravna.profile?["account_id"]
        ?.toString() ??
    pravna.profile?["accountid"]
        ?.toString() ??
    "";

final res = await _api.get(
  "start_register.php?cid=$accountId",
);

    if (loaderOpened && mounted) {

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      loaderOpened = false;
    }

    if (res is! Map ||
        res["success"] != true) {

      throw Exception(
        res is Map
            ? (res["message"] ??
                "Greška")
            : "Greška",
      );
    }

    final String url =
        (res["redirectUrl"] ?? "")
            .toString();

    if (url.isEmpty) {

      throw Exception(
        "BANKART_REDIRECT_MISSING",
      );
    }

    if (!mounted) return;

await Navigator.push(

  context,

  MaterialPageRoute(
    builder: (_) =>
        PaymentWebviewPage(
      paymentUrl: url,
    ),
  ),
);

/*
=========================================
OBAVEZAN REFRESH NAKON POVRATKA
=========================================
*/

await Future.delayed(
  const Duration(seconds: 2),
);

await _loadAll();

if (!mounted) return;

ScaffoldMessenger.of(
  context,
).showSnackBar(
  const SnackBar(
    content: Text(
      "Kartice osvježene",
    ),
  ),
); 
  } catch (e) {

    if (loaderOpened &&
        mounted) {

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
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

      backgroundColor:
          const Color(0xFFEAF4FF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Profil firme",
        ),
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text(_error!),
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: ListView(
                    padding:
                        const EdgeInsets.all(16),
                    children: [

                      _section(
                        title:
                            "Podaci o firmi",
                        child: Column(
                          children: [

                            _row(
                              "Naziv",
                              _txt(
                                _company[
                                    "accountname"],
                              ),
                            ),

                            _row(
                              "ID broj",
                              _txt(
                                _company[
                                    "cf_928"],
                              ),
                            ),

                            _row(
                              "PDV broj",
                              _txt(
                                _company[
                                    "cf_936"],
                              ),
                            ),

                            _row(
                              "Email",
                              _txt(
                                _company[
                                    "email1"],
                              ),
                            ),

                            _row(
                              "Telefon",
                              _txt(
                                _company[
                                    "phone"],
                              ),
                            ),

                            _row(
                              "Adresa",
                              _txt(
                                _company[
                                    "bill_street"],
                              ),
                            ),

                            _row(
                              "Poštanski broj",
                              _txt(
                                _company[
                                    "bill_code"],
                              ),
                            ),

                            _row(
                              "Grad",
                              _txt(
                                _company[
                                    "bill_city"],
                              ),
                            ),

                          ],
                        ),
                      ),

                      _listSection(
                        "Moji Ugovori",
                        _contracts,
                      ),

                      _listSection(
                        "Narudžbe",
                        _orders,
                      ),
					  
					  _listSection(
						"Moji nalozi",
						_tickets,
						),
						
						_cardsSection(),

                      _listSection(
                        "Fakture",
                        _invoices,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      ElevatedButton.icon(

                        onPressed: _logout,

                        icon:
                            const Icon(Icons.logout),

                        label:
                            const Text("Odjava"),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          foregroundColor:
                              Colors.white,
                          minimumSize:
                              const Size(
                            double.infinity,
                            52,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
    );
  }

  Widget _listSection(
    String title,
    List data,
  ) {

    return _section(

      title: title,

      child: data.isEmpty

          ? const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Text(
                "Nema podataka",
              ),
            )

          : Column(
              children: data.map((e) {

                final broj =
				    e["ticket_no"] ??
                    e["contract_no"] ??
                    e["salesorder_no"] ??
                    e["invoice_no"] ??
                    e["subject"] ??
                    "-";

                final status =
				    e["contract_status"] ??
                    e["status"] ??
                    e["sostatus"] ??
                    e["invoicestatus"] ??
                    "-";

                final datum =
                    e["start_date"] ??
                    e["duedate"] ??
                    e["createdtime"] ??
                    e["modifiedtime"] ??
                    "-";

                final iznos =
                    e["hdnGrandTotal"] ??
                    e["total"] ??
                    e["subtotal"] ??
                    "-";

                return Container(

                  width: double.infinity,

                  margin: const EdgeInsets.only(
                    bottom: 12,
                  ),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.black12,
                    ),

                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        broj.toString(),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _infoRow(
                        "Status",
                        status.toString(),
                      ),

                      _infoRow(
                        "Datum",
                        datum.toString(),
                      ),

                      _infoRow(
                        "Iznos",
                        iznos.toString(),
                      ),

                      if (e["subject"] != null)
                        _infoRow(
                          "Naziv",
                          e["subject"]
                              .toString(),
                        ),

                    ],
                  ),
                );

              }).toList(),
            ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          child,

        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? "-"
                  : value,
            ),
          ),

        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty
                  ? "-"
                  : value,
            ),
          ),

        ],
      ),
    );
  }

 String _txt(dynamic v) {
  if (v == null) return "";
  return v.toString();
}

Widget _cardsSection() {

  return _section(

    title: "Moje kartice",

child: Column(
  children: [

    if (_cards.isEmpty)

      const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Text(
          "Nema registrovanih kartica",
        ),
      )

    else

      ..._cards.map((card) {

        final masked =
            card["maskedpan"]
                ?.toString() ??
            "****";

        final holder =
            card["cardholder"]
                ?.toString() ??
            "-";

        final brand =
            card["brand"]
                ?.toString() ??
            "Kartica";

        return Container(

          width: double.infinity,

          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),

          padding:
              const EdgeInsets.all(
            16,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border: Border.all(
              color:
                  Colors.black12,
            ),

          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const Icon(
                    Icons.credit_card,
                    size: 28,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      brand,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                    ),

                    onPressed: () async {

                      final paymentId =
                          card["paymentid"]
                              ?.toString() ??
                          "";

                      final confirm =
                          await showDialog(

                        context: context,

                        builder: (_) =>
                            AlertDialog(

                          title: const Text(
                            "Potvrda",
                          ),

                          content:
                              const Text(
                            "Da li želite deregistrirati karticu?",
                          ),

                          actions: [

                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  false,
                                );
                              },
                              child:
                                  const Text(
                                "Ne",
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  true,
                                );
                              },
                              child:
                                  const Text(
                                "Da",
                              ),
                            ),

                          ],
                        ),
                      );

                      if (confirm != true) {
                        return;
                      }

                      final res =
                          await _api.postAbsolute(
                        "https://www.majstor24.ba/api/payment/deregister.php",
                        body: {
                          "paymentid":
                              paymentId,
                        },
                      );

                      if (res["success"] ==
                          true) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Kartica deregistrirana",
                            ),
                          ),
                        );

                        _loadAll();
                      }
                    },

                    child: const Text(
                      "Deregistriraj",
                    ),
                  ),

                ],
              ),




    const SizedBox(
      height: 14,
    ),

    Text(
      masked,
      style:
          const TextStyle(
        fontSize: 22,
        fontWeight:
            FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),

    const SizedBox(
      height: 12,
    ),

    _infoRow(
      "Vlasnik",
      holder,
    ),

  ],
),
              );

         }).toList(),

const SizedBox(
  height: 10,
),

SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(

    icon: const Icon(
      Icons.add_card,
    ),

    label: const Text(
      "Registriraj novu karticu",
    ),

    onPressed: _registerCard,
  ),
),
],
          ),
  );
}

}