import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:provider/provider.dart';

import '../application/pravna_notifier.dart';
import 'ticket_confirmation_page.dart';

class NaruciAsistencijuPage extends StatefulWidget {
  const NaruciAsistencijuPage({super.key});

  @override
  State<NaruciAsistencijuPage> createState() =>
      _NaruciAsistencijuPageState();
}

class _NaruciAsistencijuPageState
    extends State<NaruciAsistencijuPage> {
  final ApiClient _api = ApiClient();

  bool loading = true;
  bool sending = false;

  Map<String, dynamic> profile = {};
  Map<String, dynamic> uslugeMap = {};

  final naslovController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();

  bool sameAddress = false;

  DateTime? selectedDate;

  String? selectedHour;
  String? selectedMinute;

  bool callMe = false;
  bool urgent = false;

  String? paymentMethod;

  File? selectedImage;

  String? selectedGroup;
  String? selectedSubgroup;

  int? selectedPrice;

  DateTime get defaultDate =>
      DateTime.now().add(
        const Duration(hours: 24),
      );

  @override
  void initState() {
    super.initState();

    selectedDate = defaultDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProfile();
      loadUsluge();
    });
  }

  Future<void> loadProfile() async {
    try {
      final pravna = context.read<PravnaNotifier>();

      profile = Map<String, dynamic>.from(
        pravna.profile ?? {},
      );

      debugPrint("PROFILE: $profile");

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadUsluge() async {
    try {
      final res = await _api.get("usluge.php");

      uslugeMap = Map<String, dynamic>.from(res);

      setState(() {});
    } catch (e) {
      debugPrint("GRESKA USLUGE: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void fillCompanyAddress(bool value) {
    setState(() {
      sameAddress = value;
    });

    if (value) {
      addressController.text =
          profile["mailingstreet"] ??
          profile["bill_street"] ??
          "";

      zipController.text =
          profile["mailingzip"] ??
          profile["bill_code"] ??
          "";

      cityController.text =
          profile["mailingcity"] ??
          profile["bill_city"] ??
          "";
    } else {
      addressController.clear();
      zipController.clear();
      cityController.clear();
    }
  }

  Future<void> openConfirmModal() async {
    if (selectedGroup == null || selectedSubgroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Popunite obavezna polja"),
        ),
      );

      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              title: const Text("Potvrda zahtjeva"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AbsorbPointer(
                      absorbing: urgent,
                      child: Opacity(
                        opacity: urgent ? 0.45 : 1,
                        child: ListTile(
                          title: Text(
                            urgent
                                ? "Datum nije potreban za hitnu intervenciju"
                                : selectedDate == null
                                    ? "Odaberite datum"
                                    : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
                          ),
                          trailing: const Icon(
                            Icons.calendar_today,
                          ),
                          onTap: urgent
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    firstDate: defaultDate,
                                    lastDate: DateTime(2030),
                                    initialDate:
                                        selectedDate ?? defaultDate,
                                  );

                                  if (picked != null) {
                                    setModal(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedHour,
                            decoration: const InputDecoration(
                              labelText: "Sat",
                            ),
                            items: List.generate(
                              12,
                              (i) {
                                final h = (i + 8)
                                    .toString()
                                    .padLeft(2, '0');

                                return DropdownMenuItem(
                                  value: h,
                                  child: Text(h),
                                );
                              },
                            ),
                            onChanged: (v) {
                              setModal(() {
                                selectedHour = v;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedMinute,
                            decoration: const InputDecoration(
                              labelText: "Min",
                            ),
                            items: [
                              "00",
                              "15",
                              "30",
                              "45"
                            ].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) {
                              setModal(() {
                                selectedMinute = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    CheckboxListTile(
                      value: callMe,
                      onChanged: (v) {
                        setModal(() {
                          callMe = v ?? false;
                        });
                      },
                      title: const Text(
                        "Neka me majstor nazove",
                      ),
                    ),

                    CheckboxListTile(
                      value: urgent,
                      onChanged: (v) {
                        setModal(() {
                          urgent = v ?? false;

                          if (urgent) {
                            selectedDate = null;
                          } else {
                            selectedDate = defaultDate;
                          }
                        });
                      },
                      title: const Text(
                        "Hitna intervencija",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Nazad"),
                ),

 ElevatedButton(
  onPressed: () async {

    if (!callMe &&
        !urgent &&
        (selectedDate == null ||
            selectedHour == null ||
            selectedMinute == null)) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Odaberite termin"),
        ),
      );

      return;
    }

    Navigator.pop(context);

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => TicketConfirmationPage(

          selectedDate:
              selectedDate,

          selectedHour:
              selectedHour,

          selectedMinute:
              selectedMinute,

          callMe:
              callMe,

          urgent:
              urgent,

          selectedGroup:
              selectedGroup,

          selectedSubgroup:
              selectedSubgroup,

          selectedPrice:
              selectedPrice,

          naslov:
              naslovController.text.trim(),

          address:
              addressController.text.trim(),

          zip:
              zipController.text.trim(),

          city:
              cityController.text.trim(),

          profile:
              profile,

          paymentMethod:
              paymentMethod,

          selectedImage:
              selectedImage,
        ),
      ),
    );
  },

  child: const Text("Dalje"),
),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openPaymentModal() async {
    final clanskiController = TextEditingController();

    bool validating = false;
    bool clanskiValid = false;

    String clanskiMessage = "";

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              title: const Text("Način plaćanja"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: "karticno",
                      groupValue: paymentMethod,
                      onChanged: (v) {
                        setState(() {
                          paymentMethod = v;
                        });

                        setModal(() {});
                      },
                      title: const Text("Kartično"),
                    ),

                    RadioListTile<String>(
                      value: "gotovina",
                      groupValue: paymentMethod,
                      onChanged: (v) {
                        setState(() {
                          paymentMethod = v;
                        });

                        setModal(() {});
                      },
                      title: const Text("Gotovina"),
                    ),

                    RadioListTile<String>(
                      value: "ziralno",
                      groupValue: paymentMethod,
                      onChanged: (v) {
                        setState(() {
                          paymentMethod = v;
                        });

                        setModal(() {});
                      },
                      title: const Text("Žiralno"),
                    ),

                    RadioListTile<String>(
                      value: "clanski",
                      groupValue: paymentMethod,
                      onChanged: (v) {
                        setState(() {
                          paymentMethod = v;
                        });

                        setModal(() {});
                      },
                      title: const Text("Članski bonitet"),
                    ),

                    if (paymentMethod == "clanski") ...[
                      const SizedBox(height: 14),

                      TextField(
                        controller: clanskiController,
                        decoration: const InputDecoration(
                          labelText: "Unesite članski broj",
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: validating
                              ? null
                              : () async {
                                  setModal(() {
                                    validating = true;
                                  });

                                  try {
                                    final res = await _api.post(
                                      "validate_clanski_mobile.php",
                                      body: {
                                        "broj": clanskiController.text.trim(),
                                      },
                                    );

                                    if (res["success"] == true) {
                                      clanskiValid = true;
                                      clanskiMessage =
                                          "✅ Članska prava su validna";
                                    } else {
                                      clanskiValid = false;
                                      clanskiMessage =
                                          res["message"] ??
                                              "❌ Članska prava nisu validna";
                                    }
                                  } catch (e) {
                                    clanskiValid = false;
                                    clanskiMessage =
                                        "❌ Greška validacije";
                                  }

                                  setModal(() {
                                    validating = false;
                                  });
                                },
                          child: validating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Provjeri prava"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        clanskiMessage,
                        style: TextStyle(
                          color: clanskiValid
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    if (paymentMethod == "ziralno") ...[
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Uplatnica će biti generisana nakon potvrde.",
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Pregled uplatnice će biti dodat u narednom koraku",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text("Pogledaj uplatnicu"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Nazad"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (paymentMethod == null) {
                      return;
                    }

                    if (paymentMethod == "clanski" && !clanskiValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Članska prava nisu validna",
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(context);

                    if (paymentMethod == "karticno") {
                      try {
                        final amount = selectedPrice ?? 0;

                        if (amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Neispravan iznos"),
                            ),
                          );

                          return;
                        }

                        final res = await _api.postAbsolute(
                          "https://www.majstor24.ba/placanje/start_transaction_saved_ticket_mobile.php",
                          body: {
                            "bankart_ws_id": "1",
                            "amount": amount,
                            "currency": "BAM",
                            "merchant_trx_id":
                                "APP-${DateTime.now().millisecondsSinceEpoch}",
                          },
                        );

                        debugPrint("BANKART RESPONSE: $res");

                        if (res["success"] == true &&
                            res["redirect"] != null) {
                          final url = Uri.parse(
                            res["redirect"],
                          );

                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );

                          return;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res["message"] ??
                                    "Greška pokretanja plaćanja",
                              ),
                            ),
                          );

                          return;
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Greška: $e"),
                          ),
                        );

                        return;
                      }
                    }

                    await submitTicket();
                  },
                  child: const Text("Potvrdi"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> submitTicket() async {
    setState(() {
      sending = true;
    });

    try {
      final body = {
        "account_id":
            profile["account_id_raw"]?.toString() ?? "",

        "group_service": selectedGroup ?? "",

        "sub_service": selectedSubgroup ?? "",

        "price": selectedPrice?.toString() ?? "",

        "title": naslovController.text.trim().isEmpty
            ? "Zahtjev za asistenciju"
            : naslovController.text.trim(),

        "description": naslovController.text.trim().isEmpty
            ? "Zahtjev poslan putem mobilne aplikacije"
            : naslovController.text.trim(),

        "address": addressController.text.trim(),

        "zip": zipController.text.trim(),

        "city": cityController.text.trim(),

        "datum_intervencije": selectedDate != null
            ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
            : "",

        "vrijeme_intervencije":
            selectedHour != null && selectedMinute != null
                ? "$selectedHour:$selectedMinute"
                : "",

        "poziv_majstora": callMe ? "1" : "0",

        "hitna_intervencija": urgent ? "1" : "0",

        "payment_method": paymentMethod ?? "",
      };

      final res = await _api.post(
        "create_ticket_pravna_flutter.php",
        body: body,
      );

      debugPrint("TICKET RESPONSE: $res");

      if (!mounted) return;

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Zahtjev uspješno poslan"),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res["msg"] ??
                  res["message"] ??
                  "Greška",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška: $e"),
        ),
      );
    }

    setState(() {
      sending = false;
    });
  }

  Widget infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 14),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading || uslugeMap.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FF),
      appBar: AppBar(
        title: const Text("Naruči asistenciju"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            infoCard(
              title: "Podaci o firmi",
              children: [
                infoRow(
                  "Naziv",
                  profile["accountname"] ?? "",
                ),

                infoRow(
                  "Email",
                  profile["email"] ?? "",
                ),

                infoRow(
                  "Telefon",
                  profile["phone"] ?? "",
                ),

                infoRow(
                  "Adresa",
                  profile["mailingstreet"] ??
                      profile["bill_street"] ??
                      "",
                ),

                infoRow(
                  "Poštanski broj",
                  profile["mailingzip"] ??
                      profile["bill_code"] ??
                      "",
                ),

                infoRow(
                  "Grad",
                  profile["mailingcity"] ??
                      profile["bill_city"] ??
                      "",
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    decoration: const InputDecoration(
                      labelText: "Grupa usluga",
                    ),
                    items: uslugeMap.keys.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedGroup = v;
                        selectedSubgroup = null;
                        selectedPrice = null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedSubgroup,
                    decoration: const InputDecoration(
                      labelText:
                          "Podgrupa usluga (Cijena dolaska i prvog Norma-sata rada)",
                    ),
                    items: selectedGroup == null
                        ? []
                        : (uslugeMap[selectedGroup!]
                                as Map<String, dynamic>)
                            .keys
                            .map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSubgroup = v;

                        if (selectedGroup != null &&
                            selectedSubgroup != null) {
                          selectedPrice =
                              uslugeMap[selectedGroup!]
                                  [selectedSubgroup!];
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedPrice != null
                          ? "$selectedPrice KM"
                          : "",
                    ),
                    decoration: const InputDecoration(
                      labelText: "Cijena (KM)",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: naslovController,
                    minLines: 2,
                    maxLines: 2,
                    style: const TextStyle(
                      height: 0.75,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Napomene",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  CheckboxListTile(
                    value: sameAddress,
                    onChanged: (v) {
                      fillCompanyAddress(
                        v ?? false,
                      );
                    },
                    title: const Text("Ista kao firma"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: "Adresa",
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: zipController,
                    decoration: const InputDecoration(
                      labelText: "Poštanski broj",
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "Grad",
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        selectedImage!,
                        height: 160,
                      ),
                    ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Dodaj sliku"),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      onPressed: sending ? null : openConfirmModal,
                      child: sending
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Pošalji zahtjev"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}