import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pdf_preview_page.dart';
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

  final TextEditingController adresa = TextEditingController();
  final TextEditingController ptt = TextEditingController();
  final TextEditingController mjesto = TextEditingController();

  bool useFirma = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _txt(dynamic v) => v?.toString() ?? "";

  Future<void> _loadData() async {
    try {
      final korpaRes = await _api.get("korpa.php");

      if (!mounted) return;

      setState(() {
        _korpa = korpaRes["korpa"] ?? [];
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
      t += double.tryParse(_txt(p["cijena"])) ?? 0;
    }
    return t;
  }

  String _datumAktivacije() {
    final d = DateTime.now().add(const Duration(days: 15));
    final dan = d.day.toString().padLeft(2, "0");
    final mjesec = d.month.toString().padLeft(2, "0");
    return "$dan-$mjesec-${d.year}";
  }

  Future<void> _popuniPodatkeFirme(StateSetter setModalState) async {
    final pravna = context.read<PravnaNotifier>();
    final profile = pravna.profile;

    String a = _txt(profile?["mailingstreet"]);
    String z = _txt(profile?["mailingzip"]);
    String c = _txt(profile?["mailingcity"]);

    if (a.isEmpty) a = _txt(profile?["bill_street"]);
    if (z.isEmpty) z = _txt(profile?["bill_code"]);
    if (c.isEmpty) c = _txt(profile?["bill_city"]);

    if (a.isNotEmpty && z.isNotEmpty && c.isNotEmpty) {
      setModalState(() {
        adresa.text = a;
        ptt.text = z;
        mjesto.text = c;
      });
      return;
    }

    final accountId = profile?["account_id"];

    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nema account_id")),
      );
      return;
    }

    try {
      final res = await _api.post(
        "get_company_profile.php",
        body: {
          "account_id": accountId.toString(),
        },
      );

      if (res["success"] == true && res["data"] != null) {
        final p = res["data"];

        setModalState(() {
          adresa.text = _txt(p["bill_street"] ?? p["address"]);
          ptt.text = _txt(p["bill_code"] ?? p["zip"]);
          mjesto.text = _txt(p["bill_city"] ?? p["city"]);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nema podataka o firmi")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  void _openUnosModal(String naziv, String opis, int cijena) {
    adresa.clear();
    ptt.clear();
    mjesto.clear();
    useFirma = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text("Unos podataka ($naziv)"),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: adresa,
                      decoration: const InputDecoration(labelText: "Adresa"),
                    ),
                    TextField(
                      controller: ptt,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "PTT"),
                    ),
                    TextField(
                      controller: mjesto,
                      decoration: const InputDecoration(labelText: "Mjesto"),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: useFirma,
                          onChanged: (val) async {
                            setModalState(() {
                              useFirma = val ?? false;
                            });

                            if (useFirma) {
                              await _popuniPodatkeFirme(setModalState);
                            } else {
                              setModalState(() {
                                adresa.clear();
                                ptt.clear();
                                mjesto.clear();
                              });
                            }
                          },
                        ),
                        const Text("Ista kao firma"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Otkaži"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (adresa.text.trim().isEmpty ||
                      ptt.text.trim().isEmpty ||
                      mjesto.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Popuni sva polja")),
                    );
                    return;
                  }

                  await _api.post("korpa.php", body: {
                    "naziv": naziv,
                    "opis": opis,
                    "cijena": cijena,
                    "adresa": adresa.text.trim(),
                    "ptt": ptt.text.trim(),
                    "mjesto": mjesto.text.trim(),
                  });

                  if (!mounted) return;

                  Navigator.pop(context);
                  await _loadData();
                },
                child: const Text("Dodaj u korpu"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _clearKorpa() async {
    await _api.post("korpa.php", body: {"action": "clear"});
    await _loadData();
  }

  void _openRekap() {
    if (_korpa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korpa je prazna")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rekapitulacija i potvrda ugovora"),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _korpa.length,
                    itemBuilder: (_, i) {
                      final p = _korpa[i];

                      return ListTile(
                        title: Text("${p["naziv"]} - ${p["cijena"]} KM"),
                        subtitle: Text(
                          "${p["adresa"]}, ${p["ptt"]} ${p["mjesto"]}",
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Odabrani ugovori postaju aktivni ${_datumAktivacije()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Klikom na potvrdi potvrđujete prihvatanje ugovora.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nazad"),
            ),
            ElevatedButton(
              onPressed: _potvrdi,
              child: const Text("Potvrdi i generiši ugovor"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _potvrdi() async {
    final pravna = context.read<PravnaNotifier>();
    final profile = pravna.profile;

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nema profila firme")),
      );
      return;
    }

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _api.post("create_service_contract.php", body: {
        "account_id": profile["account_id"],
        "korpa": _korpa,
      });

      final pdfRes = await _api.post("generate_contract_pdf.php", body: {
        "company_name": profile["accountname"],
        "address": profile["bill_street"] ?? profile["mailingstreet"],
        "city": profile["bill_city"] ?? profile["mailingcity"],
        "korpa": _korpa,
      });

      if (!mounted) return;
      Navigator.pop(context);

      if (pdfRes["success"] != true || pdfRes["pdf_url"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF greška: $pdfRes")),
        );
        return;
      }

      final pdfUrl = pdfRes["pdf_url"].toString();

      await _api.post("korpa.php", body: {"action": "clear"});
      await _loadData();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewPage(url: pdfUrl),
        ),
      );

      _openEmailModal(
        _txt(profile["email1"] ?? profile["email"]),
        pdfUrl,
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: $e")),
        );
      }
    }
  }

  void _openEmailModal(String email, String pdfUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Pošalji ugovor"),
          content: Text(
            email.isEmpty
                ? "Email nije pronađen. Provjeri profil firme."
                : "Poslati ugovor na $email?",
          ),
          actions: [
            if (email.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  await _api.post("send_contract_email.php", body: {
                    "email": email,
                    "pdf_url": pdfUrl,
                  });

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email poslan")),
                  );
                },
                child: const Text("Pošalji na email"),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Zatvori"),
            ),
          ],
        );
      },
    );
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$opis\n$cijena KM / po započetom mjesecu"),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => _openUnosModal(naziv, opis, cijena),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pregled paketa i ugovaranje")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment),
              label: const Text("Aktivni ugovori"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AktivniUgovoriPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "💼 Vaši paketi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 8),

            if (_korpa.isEmpty)
              const Text("Korpa je prazna")
            else
              Column(
                children: _korpa.map((p) {
                  return Card(
                    child: ListTile(
                      title: Text(_txt(p["naziv"])),
                      subtitle: Text(
                        "Adresa: ${_txt(p["adresa"]).isEmpty ? "-" : _txt(p["adresa"])}\n"
                        "PTT: ${_txt(p["ptt"]).isEmpty ? "-" : _txt(p["ptt"])}\n"
                        "Mjesto: ${_txt(p["mjesto"]).isEmpty ? "-" : _txt(p["mjesto"])}",
                      ),
                      trailing: Text("${_txt(p["cijena"])} KM"),
                    ),
                  );
                }).toList(),
              ),

            Row(
              children: [
                OutlinedButton(
                  onPressed: _korpa.isEmpty ? null : _clearKorpa,
                  child: const Text("Isprazni"),
                ),
                const Spacer(),
                Text(
                  "Ukupno: ${_total().toStringAsFixed(2)} KM",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Želite li ugovoriti business Majstor24 servis za firme?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 12),

            const Text(
              "💡 Izaberi paket:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

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
                child: const Text("Pregled i ugovaranje paketa"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}