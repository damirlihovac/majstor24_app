import 'package:flutter/material.dart';

class TicketSuccessPage
    extends StatelessWidget {

  const TicketSuccessPage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFE6F2FF),

      appBar: AppBar(

        backgroundColor:
            Colors.red,

        title: const Text(
          "Zahtjev uspješno kreiran",
        ),

        automaticallyImplyLeading:
            false,
      ),

      body: Center(

        child: Padding(

          padding:
              const EdgeInsets.all(24),

          child: Container(

            width: double.infinity,

            padding:
                const EdgeInsets.all(24),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(

                  Icons.check_circle,

                  color: Colors.green,

                  size: 90,
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(

                  "Zahtjev uspješno kreiran",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(

                  "Vaš zahtjev je uspješno evidentiran u sistemu. Majstor će vas kontaktirati u najkraćem roku.",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                SizedBox(

                  width:
                      double.infinity,

                  child:
                      ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.red,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),

                    onPressed: () {

                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.isFirst,
                      );
                    },

                    child: const Text(
                      "Početna",
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