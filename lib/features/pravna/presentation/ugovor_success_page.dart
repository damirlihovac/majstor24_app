import 'package:flutter/material.dart';

class UgovorSuccessPage extends StatelessWidget {

  final String email;
  final String pdfUrl;
  final dynamic profile;
  final List korpa;

  const UgovorSuccessPage({
    super.key,
    required this.email,
    required this.pdfUrl,
    required this.profile,
    required this.korpa,
  });

  String _datum() {

    final d = DateTime.now().add(
      const Duration(days: 15),
    );

    return
        "${d.day.toString().padLeft(2, "0")}."
        "${d.month.toString().padLeft(2, "0")}."
        "${d.year}.";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFE6F2FF),

      appBar: AppBar(
        title: const Text("Ugovor"),
      ),

      body: Center(

        child: Card(

          margin:
              const EdgeInsets.all(20),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Padding(

            padding:
                const EdgeInsets.all(20),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 70,
                ),

                const SizedBox(height: 15),

                const Text(

                  "✅ Ugovor je uspješno generisan",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 15),

                Text(

                  "Ugovor je poslan na email:\n$email",

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(

                  "Molimo da ugovor isprintate i ovjerite.",

                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 15),

                const Text(

                  "PGM Assistance BH d.o.o.\n"
                  "Vrazova 24\n"
                  "71000 Sarajevo",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(

                  "Ugovor stupa na snagu od dana ${_datum()}",

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },

                    child: const Text(
                      "Nazad na profil firme",
                    ),
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