import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/core/auth/auth_storage.dart';

class UnosPaketaModal extends StatefulWidget {
  final Map<String, dynamic> paket;
  final Map<String, dynamic>? initialData;
  final bool isEdit;

  const UnosPaketaModal({
    super.key,
    required this.paket,
    this.initialData,
    this.isEdit = false,
  });

  @override
  State<UnosPaketaModal> createState() => _UnosPaketaModalState();
}

class _UnosPaketaModalState extends State<UnosPaketaModal> {

  final ApiClient _api = ApiClient();
  final AuthStorage _storage = AuthStorage();

  final imeCtrl = TextEditingController();
  final adresaCtrl = TextEditingController();
  final pttCtrl = TextEditingController();
  final mjestoCtrl = TextEditingController();

  bool useMyData = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      imeCtrl.text = widget.initialData!['vlasnik'] ?? '';
      adresaCtrl.text = widget.initialData!['adresa'] ?? '';
      pttCtrl.text = widget.initialData!['ptt'] ?? '';
      mjestoCtrl.text = widget.initialData!['mjesto'] ?? '';
    }
  }

  @override
  void dispose() {
    imeCtrl.dispose();
    adresaCtrl.dispose();
    pttCtrl.dispose();
    mjestoCtrl.dispose();
    super.dispose();
  }

  /* ========================================
     ACTIVATION DATE (+15 DAYS)
  ======================================== */

  DateTime _activationDateTime() {
    final now = DateTime.now();
    return now.add(const Duration(days: 15));
  }

  String _formatActivation(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}."
        "${d.month.toString().padLeft(2, '0')}."
        "${d.year} u "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')} sati";
  }

  /* ========================================
     LOAD USER DATA
  ======================================== */

  Future<void> _loadUserData() async {

    try {

      final res = await _api.get("profile/dashboard.php");

      if (res["success"] == true) {

        final profile = res["profile"];

        setState(() {

          imeCtrl.text =
              "${profile["firstname"] ?? ""} ${profile["lastname"] ?? ""}".trim();

          adresaCtrl.text = profile["mailingstreet"] ?? "";
          pttCtrl.text    = profile["mailingzip"] ?? "";
          mjestoCtrl.text = profile["mailingcity"] ?? "";

        });

      }

    } catch (_) {

      final street = await _storage.getMailingStreet() ?? "";
      final zip = await _storage.getMailingZip() ?? "";
      final city = await _storage.getMailingCity() ?? "";

      setState(() {

        imeCtrl.text = "";
        adresaCtrl.text = street;
        pttCtrl.text = zip;
        mjestoCtrl.text = city;

      });

    }

  }

  void _clearFields() {
    imeCtrl.clear();
    adresaCtrl.clear();
    pttCtrl.clear();
    mjestoCtrl.clear();
  }

  void _submit() {

    final ime = imeCtrl.text.trim();
    final adresa = adresaCtrl.text.trim();
    final ptt = pttCtrl.text.trim();
    final mjesto = mjestoCtrl.text.trim();

    if (ime.isEmpty || adresa.isEmpty || ptt.isEmpty || mjesto.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sva polja su obavezna.")),
      );
      return;

    }

    final p = widget.paket;

    final item = <String, dynamic>{
      "paket_id": p["id"],
      "naziv": p["naziv"],
      "opis": p["opis"],
      "cijena": p["cijena"],
      "vlasnik": ime,
      "adresa": adresa,
      "ptt": ptt,
      "mjesto": mjesto,
    };

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {

    final paket = widget.paket;
    final activation = _activationDateTime();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              widget.isEdit ? "Ažuriraj podatke o objektu" : "Podaci o objektu",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 12),

            Text(
              paket["naziv"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              paket["opis"],
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 8),

            Text(
              "${(paket["cijena"] as double).toStringAsFixed(2)} KM",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            /// ✅ ACTIVATION INFO
            Text(
              "Kupljeni paket će biti aktivan od ${_formatActivation(activation)}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            /// CHECKBOX
            CheckboxListTile(
              value: useMyData,
              onChanged: (v) async {

                setState(() => useMyData = v ?? false);

                if (useMyData) {
                  await _loadUserData();
                } else {
                  _clearFields();
                }

              },
              contentPadding: EdgeInsets.zero,
              title: const Text("Upiši moje podatke"),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: imeCtrl,
              decoration: const InputDecoration(
                labelText: "Ime i prezime vlasnika",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: adresaCtrl,
              decoration: const InputDecoration(
                labelText: "Adresa objekta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: pttCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "PTT broj objekta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: mjestoCtrl,
              decoration: const InputDecoration(
                labelText: "Mjesto objekta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Odustani"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.isEdit ? "Sačuvaj" : "Dodaj"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}