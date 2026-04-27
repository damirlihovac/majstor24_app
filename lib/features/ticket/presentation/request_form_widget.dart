import 'package:flutter/material.dart';
import 'package:majstor24_app/features/ticket/presentation/request_confirmation_page.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/core/auth/auth_storage.dart';
import 'request_confirmation_modal.dart';
import 'request_confirmation_page.dart';

class RequestFormWidget extends StatefulWidget {
  const RequestFormWidget({super.key});

  @override
  State<RequestFormWidget> createState() => _RequestFormWidgetState();
}

class _RequestFormWidgetState extends State<RequestFormWidget> {
  final ApiClient _api = ApiClient();
  final AuthStorage _storage = AuthStorage();

  final _streetCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _sameAddress = true;
  bool _loading = false;

  String? _selectedService;
  String? _selectedSubgroup;
  double _price = 0;

  final Map<String, Map<String, double>> _services = {
    "Vodoinstalater": {
      "Otčepljivanje odvoda i kanalizacije": 65,
      "Popravka ili zamjena slavine": 60,
      "Sanacija curenja cijevi": 80,
      "Zamjena sifona": 50,
      "Ugradnja i zamjena WC šolje": 125,
      "Popravka ili zamjena vodokotlića": 60,
      "Priključenje mašine za veš ili suđe": 70,
      "Ugradnja i zamjena bojlera (električni)": 140,
      "Zamjena ili popravak tuša i baterija": 50,
      "Manji radovi na instalaciji grijanja": 60,
      "Ostalo": 100,
    },
    "Električar": {
      "Zamjena osigurača ili automatske sklopke": 40,
      "Popravka prekidača/utičnica": 40,
      "Ugradnja nove utičnice": 50,
      "Rasvjetna tijela": 60,
      "Kratki spoj": 70,
      "Interfon": 60,
      "Instalacija rasvjete": 60,
      "Spajanje šporeta": 80,
      "Nestanak struje": 70,
      "Razvodna kutija": 90,
      "Ostalo": 100,
    },
    "Ključar": {
      "Otvaranje stana": 80,
      "Otvaranje sigurnosnih vrata": 100,
      "Zamjena cilindra": 80,
      "Zamjena sigurnosne brave": 100,
      "Ugradnja brava": 70,
      "Dodatna sigurnosna brava": 150,
      "Popravka brava": 50,
      "Servis brave": 100,
      "Ostalo": 100,
    },
    "Grijanje": {
      "Odzračivanje radijatora": 50,
      "Popravka curenja na radijatoru": 80,
      "Zamjena termostatskog ventila": 70,
      "Popravka ili zamjena cirkulacione pumpe": 120,
      "Provjera i osnovni servis sistema grijanja": 100,
      "Ostalo": 100,
    },
    "Bijela tehnika": {
      "Popravka veš mašine": 90,
      "Popravka mašine za suđe": 90,
      "Popravka frižidera": 100,
      "Popravka rerne ili ploče": 80,
      "Dijagnostika kvara uređaja": 70,
      "Ostalo": 100,
    },
    "Klima uređaji": {
      "Redovan servis i čišćenje klime": 70,
      "Punjenje klime freonom": 120,
      "Popravka unutrašnje jedinice": 90,
      "Popravka vanjske jedinice": 110,
      "Dijagnostika kvara klima uređaja": 80,
      "Ostalo": 100,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    try {
      final res = await _api.get("profile/dashboard.php");

      if (!mounted) return;

      if (res["success"] == true) {
        final profile = res["profile"] ?? {};

        setState(() {
          _streetCtrl.text = profile["mailingstreet"] ?? "";
          _zipCtrl.text = profile["mailingzip"] ?? "";
          _cityCtrl.text = profile["mailingcity"] ?? "";
        });
      }
    } catch (_) {
      final street = await _storage.getMailingStreet() ?? "";
      final zip = await _storage.getMailingZip() ?? "";
      final city = await _storage.getMailingCity() ?? "";

      if (!mounted) return;

      setState(() {
        _streetCtrl.text = street;
        _zipCtrl.text = zip;
        _cityCtrl.text = city;
      });
    }
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  Future<void> _submitRequest() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    final street = _streetCtrl.text.trim();
    final zip = _zipCtrl.text.trim();
    final city = _cityCtrl.text.trim();

    if (street.isEmpty || zip.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite adresu")),
      );
      return;
    }

    if (_selectedService == null || _selectedSubgroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Odaberite uslugu")),
      );
      return;
    }

    final modalResult =
        await showModalBottomSheet<RequestConfirmationModalResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RequestConfirmationModal(),
    );

    if (modalResult == null) return;

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final payload = {
        "request": {
          "adresa": street,
          "ptt": zip,
          "mjesto": city,
          "usluga": _selectedService,
          "podgrupa": _selectedSubgroup,
          "cijena": _price,
          "napomene": _noteCtrl.text.trim(),
        },
        "termin": modalResult.toJson(),
      };

      final res = await _api.post(
        "ticket/confirm_mobile.php",
        body: payload,
      );

      if (!mounted) return;

      if (res["success"] == true) {
        final placanje = res["placanje"] ?? {};
        final trx = (placanje["merchant_trx_id"] ?? "").toString();

        if (trx.isEmpty) {
          throw Exception("merchant_trx_id nedostaje");
        }

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RequestConfirmationPage(trx: trx),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Greška")),
        );
      }
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
  void dispose() {
    _streetCtrl.dispose();
    _zipCtrl.dispose();
    _cityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subgroups = _selectedService == null
        ? <String>[]
        : _services[_selectedService]!.keys.toList();

    return AbsorbPointer(
      absorbing: _loading,
      child: Column(
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Asistencije je na mojoj adresi"),
            value: _sameAddress,
            onChanged: (v) async {
              setState(() => _sameAddress = v ?? true);

              if (_sameAddress) {
                await _loadUserAddress();
              } else {
                _streetCtrl.clear();
                _zipCtrl.clear();
                _cityCtrl.clear();
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _streetCtrl,
            decoration: _dec("Adresa"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _zipCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec("Poštanski broj"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _cityCtrl,
            decoration: _dec("Mjesto"),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedService,
            decoration: _dec("Odaberite vrstu majstora kojeg trebate"),
            items: _services.keys.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedService = v;
                _selectedSubgroup = null;
                _price = 0;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedSubgroup,
            decoration: _dec("Koju uslugu trebate"),
            items: subgroups.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedSubgroup = v;
                _price = _services[_selectedService]![v]!;
              });
            },
          ),
          const SizedBox(height: 10),
          if (_price > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Cijena: ${_price.toStringAsFixed(2)} BAM",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: _dec("Napomene"),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitRequest,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Pošalji zahtjev"),
            ),
          ),
        ],
      ),
    );
  }
}