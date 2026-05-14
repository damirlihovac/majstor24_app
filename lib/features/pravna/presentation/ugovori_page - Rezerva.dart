import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class UgovoriPage extends StatefulWidget {
  const UgovoriPage({super.key});

  @override
  State<UgovoriPage> createState() => _UgovoriPageState();
}

class _UgovoriPageState extends State<UgovoriPage> {

  final ApiClient api = ApiClient();

  List korpa = [];
  double total = 0;

  List ugovori = [];
  bool loadingUgovori = true;

  Map<String, dynamic>? aktivniPaket;

  final TextEditingController adresa = TextEditingController();
  final TextEditingController ptt = TextEditingController();
  final TextEditingController mjesto = TextEditingController();

  bool useFirmaData = false;

  @override
  void initState() {
    super.initState();
    getKorpa();
    getUgovori();
  }

  // ================= API =================

  Future<void> getKorpa() async {
    final res = await api.get("pravna/api/korpa.php");

    setState(() {
      korpa = res["korpa"] ?? [];
      total = 0;

      for (var p in korpa) {
        total += double.tryParse(p["cijena"].toString()) ?? 0;
      }
    });
  }

  Future<void> addKorpa(Map<String, dynamic> paket) async {
    await api.post("pravna/api/korpa.php", body: paket);
    await getKorpa();
  }

  Future<void> clearKorpa() async {
    await api.post("pravna/api/korpa.php", body: {"action": "clear"});
    await getKorpa();
  }

  Future<void> getUgovori() async {
    try {
      final res = await api.get("pravna/api/get_service_contracts_company.php");

      setState(() {
        ugovori = res["data"] ?? res["contracts"] ?? [];
        loadingUgovori = false;
      });

    } catch (e) {
      setState(() {
        loadingUgovori = false;
      });
    }
  }

  // ================= DATUM =================

  String getDatumAktivacije() {
    final datum = DateTime.now().add(const Duration(days: 15));
    return DateFormat("dd.MM.yyyy").format(datum);
  }

  // ================= MODAL UNOS =================

  void openUnosModal(Map<String, dynamic> paket) {

    aktivniPaket = paket;

    adresa.clear();
    ptt.clear();
    mjesto.clear();
    useFirmaData = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {

          return AlertDialog(
            title: const Text("Unos podataka"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: adresa,
                  enabled: !useFirmaData,
                  decoration: const InputDecoration(labelText: "Adresa"),
                ),

                TextField(
                  controller: ptt,
                  enabled: !useFirmaData,
                  decoration: const InputDecoration(labelText: "PTT"),
                ),

                TextField(
                  controller: mjesto,
                  enabled: !useFirmaData,
                  decoration: const InputDecoration(labelText: "Mjesto"),
                ),

                Row(
                  children: [
                    Checkbox(
                      value: useFirmaData,
                      onChanged: (val) async {

                        setModalState(() {
                          useFirmaData = val ?? false;
                        });

                        if (useFirmaData) {

                          final res = await api.get("pravna/api/get_company_profile.php");

                          setModalState(() {
                            adresa.text = res["address"] ?? "";
                            ptt.text = res["zip"] ?? "";
                            mjesto.text = res["city"] ?? "";
                          });

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
                )
              ],
            ),

            actions: [
              ElevatedButton(
                onPressed: () async {

                  if (adresa.text.isEmpty ||
                      ptt.text.isEmpty ||
                      mjesto.text.isEmpty) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sva polja su obavezna"))
                    );
                    return;
                  }

                  final paketData = {
                    ...aktivniPaket!,
                    "adresa": adresa.text,
                    "ptt": ptt.text,
                    "mjesto": mjesto.text
                  };

                  await addKorpa(paketData);

                  Navigator.pop(context);
                },
                child: const Text("Dodaj"),
              )
            ],
          );
        },
      ),
    );
  }

  // ================= REKAP MODAL =================

  void openRekapModal() {

    if (korpa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Korpa je prazna"))
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: const Text("Rekapitulacija i potvrda"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: korpa.length,
                  itemBuilder: (_, i) {
                    final p = korpa[i];

                    return ListTile(
                      title: Text("${p["naziv"]} - ${p["cijena"]} KM"),
                      subtitle: Text(
                        "${p["adresa"]}, ${p["ptt"]} ${p["mjesto"]}"
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Aktivacija: ${getDatumAktivacije()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "PGM Assistance BH d.o.o.\nVrazova 24\n71000 Sarajevo",
                textAlign: TextAlign.center,
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Nazad"),
            ),
            ElevatedButton(
              onPressed: potvrdiUgovor,
              child: const Text("Potvrdi"),
            )
          ],
        );
      },
    );
  }

  // ================= POTVRDA =================

  Future<void> potvrdiUgovor() async {

    Navigator.pop(context);

    await api.post(
      "pravna/api/sacuvaj_korpu_ugovor.php",
      body: {"korpa": korpa},
    );

    final url = Uri.parse(
      "https://www.majstor24.ba/pravna/api/generisi_ugovor.php"
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

    await clearKorpa();
    await getUgovori();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ugovor generisan"))
    );
  }

  // ================= UI =================

  Widget paketKartica(String naziv, String opis, int cijena) {
    return Card(
      child: ListTile(
        title: Text(naziv, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$opis\n$cijena KM / mjesečno"),
        trailing: const Icon(Icons.add),
        onTap: () => openUnosModal({
          "naziv": naziv,
          "opis": opis,
          "cijena": cijena
        }),
      ),
    );
  }

  Widget korpaItem(Map p) {
    return Card(
      child: ListTile(
        title: Text(p["naziv"]),
        subtitle: Text("${p["cijena"]} KM"),
      ),
    );
  }

  Widget ugovorItem(Map u) {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        title: Text(u["package"] ?? "Paket"),
        subtitle: Text(
          "Važi od: ${u["start_date"] ?? '-'}\nIstiče: ${u["due_date"] ?? '-'}"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Ugovori")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Aktivni ugovori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            loadingUgovori
                ? const CircularProgressIndicator()
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: ugovori.length,
                      itemBuilder: (_, i) => ugovorItem(ugovori[i]),
                    ),
                  ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Odaberite paket",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            paketKartica("bizstart", "Osnovni paket", 50),
            paketKartica("bizplus", "Plus paket", 80),
            paketKartica("bizpremium", "Premium paket", 100),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: korpa.length,
                itemBuilder: (_, i) => korpaItem(korpa[i]),
              ),
            ),

            Text("Ukupno: ${total.toStringAsFixed(2)} KM"),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: clearKorpa,
                    child: const Text("Isprazni"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: openRekapModal,
                    child: const Text("Pregled i ugovaranje"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}