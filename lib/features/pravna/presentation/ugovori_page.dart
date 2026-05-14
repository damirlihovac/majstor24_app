import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'ugovor_success_page.dart';
import 'aktivni_ugovori_page.dart';

import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/pravna/application/pravna_notifier.dart';

class UgovoriPage extends StatefulWidget {
  const UgovoriPage({super.key});

  @override
  State<UgovoriPage> createState() => _UgovoriPageState();
}

class _UgovoriPageState extends State<UgovoriPage> {

  final ApiClient _api = ApiClient();

  bool _loading = true;
  String? _error;

  List _korpa = [];

  final TextEditingController adresa =
      TextEditingController();

  final TextEditingController ptt =
      TextEditingController();

  final TextEditingController mjesto =
      TextEditingController();

  bool useFirma = false;
  bool _clearingKorpa = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    adresa.dispose();
    ptt.dispose();
    mjesto.dispose();
    super.dispose();
  }

  String _txt(dynamic v) =>
      v?.toString() ?? "";

  Future<void> _loadData() async {

    try {

      final korpaRes =
          await _api.get("korpa.php");

      if (!mounted) return;

      setState(() {

        _korpa =
            korpaRes["korpa"] ?? [];

        _error = null;
        _loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        _error = "$e";
        _loading = false;
      });
    }
  }

  double _total() {

    double t = 0;

    for (final p in _korpa) {

      t += double.tryParse(
            _txt(p["cijena"]),
          ) ??
          0;
    }

    return t;
  }

  String _datumAktivacije() {

    final d = DateTime.now().add(
      const Duration(days: 15),
    );

    final dan =
        d.day.toString().padLeft(2, "0");

    final mjesec =
        d.month.toString().padLeft(2, "0");

    return "$dan-$mjesec-${d.year}";
  }

  Future<void> _popuniPodatkeFirme(
    StateSetter setModalState,
  ) async {

    final pravna =
        context.read<PravnaNotifier>();

    final profile = pravna.profile;

    String a =
        _txt(profile?["mailingstreet"]);

    String z =
        _txt(profile?["mailingzip"]);

    String c =
        _txt(profile?["mailingcity"]);

    if (a.isEmpty) {
      a = _txt(profile?["bill_street"]);
    }

    if (z.isEmpty) {
      z = _txt(profile?["bill_code"]);
    }

    if (c.isEmpty) {
      c = _txt(profile?["bill_city"]);
    }

    setModalState(() {

      adresa.text = a;
      ptt.text = z;
      mjesto.text = c;
    });
  }

  void _openUnosModal(
    String naziv,
    String opis,
    int cijena,
  ) {

    adresa.clear();
    ptt.clear();
    mjesto.clear();

    useFirma = false;

    showDialog(

      context: context,

      builder: (_) => StatefulBuilder(

        builder: (
          context,
          setModalState,
        ) {

          return AlertDialog(

            title: Text(
              "Unos podataka ($naziv)",
            ),

            content: SizedBox(

              width: 320,

              child: SingleChildScrollView(

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    TextField(
                      controller: adresa,
                      decoration:
                          const InputDecoration(
                        labelText: "Adresa",
                      ),
                    ),

                    TextField(
                      controller: ptt,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText: "PTT",
                      ),
                    ),

                    TextField(
                      controller: mjesto,
                      decoration:
                          const InputDecoration(
                        labelText: "Mjesto",
                      ),
                    ),

                    Row(

                      children: [

                        Checkbox(

                          value: useFirma,

                          onChanged: (val) async {

                            setModalState(() {
                              useFirma =
                                  val ?? false;
                            });

                            if (useFirma) {

                              await _popuniPodatkeFirme(
                                setModalState,
                              );

                            } else {

                              setModalState(() {

                                adresa.clear();
                                ptt.clear();
                                mjesto.clear();
                              });
                            }
                          },
                        ),

                        const Text(
                          "Ista kao firma",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            actions: [

              TextButton(

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Otkaži",
                ),
              ),

              ElevatedButton(

                onPressed: () async {

                  if (
                      adresa.text.trim().isEmpty ||
                      ptt.text.trim().isEmpty ||
                      mjesto.text.trim().isEmpty
                  ) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content:
                            Text("Popuni sva polja"),
                      ),
                    );

                    return;
                  }

                  await _api.post(

                    "korpa.php",

                    body: {

                      "naziv": naziv,
                      "opis": opis,
                      "cijena": cijena,

                      "adresa":
                          adresa.text.trim(),

                      "ptt":
                          ptt.text.trim(),

                      "mjesto":
                          mjesto.text.trim(),
                    },
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  await _loadData();
                },

                child: const Text(
                  "Dodaj u korpu",
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearKorpa() async {

    if (_clearingKorpa) return;

    setState(() {
      _clearingKorpa = true;
    });

    try {

      await _api.post(

        "korpa.php",

        body: {
          "action": "clear",
          "clear": "1",
        },
      );

      if (!mounted) return;

      await _loadData();

      if (!mounted) return;

      setState(() {

        _korpa = [];
        _clearingKorpa = false;
      });

    } catch (e) {

      if (!mounted) return;
    }
  }

void _openRekap() {

  if (_korpa.isEmpty) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text("Korpa je prazna"),
      ),
    );

    return;
  }

  showDialog(

    context: context,

    builder: (_) {

      return Dialog(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        child: Container(

          padding: const EdgeInsets.all(20),

          constraints: const BoxConstraints(
            maxHeight: 650,
          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              // HEADER
              Row(

                children: [

                  const Expanded(

                    child: Text(

                      "Potvrda ugovora",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  IconButton(

                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // LISTA
              Flexible(

                child: ListView.builder(

                  shrinkWrap: true,

                  itemCount: _korpa.length,

                  itemBuilder: (_, i) {

                    final p = _korpa[i];

                    return Container(

                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        border: Border.all(
                          color: Colors.black12,
                        ),

                        borderRadius:
                            BorderRadius.circular(12),

                        color: Colors.grey.shade50,
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            "${p["naziv"]}",

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${p["cijena"]} KM",
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "${p["adresa"]}, ${p["ptt"]} ${p["mjesto"]}",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              Text(

                "Odabrani ugovori postaju aktivni ${_datumAktivacije()}",

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 18),

              const Divider(),

              const SizedBox(height: 12),

              const Text(
                "Molimo da ugovore isprintate i jedan primjerak ovjerite i pošaljete:",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  border: Border.all(
                    color: Colors.black12,
                  ),

                  borderRadius:
                      BorderRadius.circular(10),

                  color: Colors.grey.shade100,
                ),

                child: const Column(

                  children: [

                    Text(
                      "PGM Assistance BH d.o.o.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text("Vrazova 24"),

                    Text("71000 Sarajevo"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(

                children: [

                  Expanded(

                    child: OutlinedButton(

                     onPressed: () async {

  try {

    // prvo sačuvaj korpu/session
    await _api.post(

      "sacuvaj_korpu_ugovor.php",

      body: {
        "korpa": _korpa,
      },
    );

    final url = Uri.parse(
      "https://www.majstor24.ba/pravna/api/generisi_ugovor.php?preview=1",
    );

    await launchUrl(

      url,

      mode:
          LaunchMode.externalApplication,
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content:
            Text("Greška pregleda: $e"),
      ),
    );
  }
},

                      child: const Text(
                        "Pogledaj ugovor",
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),

                      onPressed:
                          _potvrdiIUgovori,

                      child: const Text(
                        "Potvrdi i generiši ugovor",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(

                "Klikom na potvrdi - potvrđujete prihvatanje",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
Future<void> _potvrdiIUgovori() async {

  final pravna =
      context.read<PravnaNotifier>();

  final profile = pravna.profile;

  if (profile == null) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
            Text("Nema profila firme"),
      ),
    );

    return;
  }

  Navigator.pop(context);

  showDialog(

    context: context,
    barrierDismissible: false,

    builder: (_) =>
        const Center(
          child:
              CircularProgressIndicator(),
        ),
  );

  try {

    final contractRes =
        await _api.post(

      "sacuvaj_korpu_ugovor.php",

      body: {

        "korpa": _korpa,

        "account_id":
            profile["account_id"]
            ?? profile["accountid"],

        "company_name":
            profile["accountname"],

        "email":
            profile["email"]
            ?? profile["email1"],

        "address":
            profile["mailingstreet"],

        "city":
            profile["mailingcity"],

        "zip":
            profile["mailingzip"],
      },
    );

    if (contractRes["success"] != true) {

      if (mounted) {

        Navigator.pop(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
                Text("Greška pri kreiranju ugovora"),
          ),
        );
      }

      return;
    }

    final genRes = await _api.get(
      "generisi_ugovor.php",
    );

    final pdfUrl =
        genRes["pdf_url"] ?? "";

    if (!mounted) return;

    Navigator.pop(context);

    await _api.post(

      "korpa.php",

      body: {

        "action": "clear",
        "clear": "1",
      },
    );

    await _loadData();

    if (!mounted) return;

    setState(() {
      _korpa = [];
    });

    final email = _txt(

      profile["email1"]
      ?? profile["email"]
      ?? "",
    ).trim();

    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            UgovorSuccessPage(

          email: email,

          pdfUrl: pdfUrl,

          profile: profile,

          korpa:
              List.from(_korpa),
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content:
            Text("Greška: $e"),
      ),
    );
  }
}

Widget _paket({

  required String naziv,
  required String opis,
  required int cijena,
  required Color color,

}) {

  return Card(

    color: color,

    child: ListTile(

      title: Text(

        naziv,

        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      subtitle: Text(
        "$opis\n$cijena KM / po započetom mjesecu",
      ),

      trailing:
          const Icon(Icons.arrow_forward),

      onTap: () =>
          _openUnosModal(
        naziv,
        opis,
        cijena,
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {

    if (_loading) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {

      return Scaffold(
        body:
            Center(child: Text(_error!)),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Pregled paketa i ugovaranje",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            ElevatedButton.icon(

              icon:
                  const Icon(Icons.assignment),

              label: const Text(
                "Aktivni ugovori",
              ),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const AktivniUgovoriPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(

              "💼 Vaši paketi",

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            if (_korpa.isEmpty)

              const Text(
                "Korpa je prazna",
              )

            else

              Column(

                children: _korpa.map((p) {

                  return Card(

                    child: ListTile(

                      title: Text(
                        _txt(p["naziv"]),
                      ),

                      subtitle: Text(

                        "Adresa: ${_txt(p["adresa"])}\n"

                        "PTT: ${_txt(p["ptt"])}\n"

                        "Mjesto: ${_txt(p["mjesto"])}",
                      ),

                      trailing: Text(
                        "${_txt(p["cijena"])} KM",
                      ),
                    ),
                  );
                }).toList(),
              ),

            Row(

              children: [

                OutlinedButton(

                  onPressed:
                      _korpa.isEmpty
                          || _clearingKorpa
                      ? null
                      : _clearKorpa,

                  child: Text(

                    _clearingKorpa
                        ? "Pražnjenje..."
                        : "Isprazni",
                  ),
                ),

                const Spacer(),

                Text(

                  "Ukupno: ${_total().toStringAsFixed(2)} KM",

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(

              "Želite li ugovoriti business Majstor24 servis za firme?",

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 12),

            _paket(
              naziv: "bizstart",
              opis: "Osnovni paket",
              cijena: 50,
              color: const Color(0xFFD3F9D8),
            ),

            _paket(
              naziv: "bizplus",
              opis: "Plus paket",
              cijena: 80,
              color: const Color(0xFFD0EBFF),
            ),

            _paket(
              naziv: "bizpremium",
              opis: "Premium paket",
              cijena: 100,
              color: const Color(0xFFFFF3BF),
            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed: _openRekap,

                child: const Text(
                  "Pregled i ugovaranje paketa",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}