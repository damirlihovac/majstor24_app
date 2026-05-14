import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/pravna_auth_notifier.dart';
import '../../pravna/presentation/pravna_home_page.dart';

class LoginPagePravna extends StatelessWidget {

  LoginPagePravna({super.key});

  final TextEditingController idbrojController =
      TextEditingController();

  final TextEditingController sifraController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    final auth =
        context.watch<PravnaAuthNotifier>();

    return Scaffold(

      backgroundColor:
          const Color(0xFFF9F9F9),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  const SizedBox(height: 20),

                  const Text(

                    'Prijava pravnog lica',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(

                    'Majstor24 Business',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(

                    controller:
                        idbrojController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        InputDecoration(

                      labelText:
                          'ID broj firme',

                      hintText:
                          '4200000000000',

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(

                    controller:
                        sifraController,

                    obscureText: true,

                    decoration:
                        InputDecoration(

                      labelText: 'Šifra',

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(

                    height: 54,

                    child: ElevatedButton(

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.red,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      onPressed:
                          auth.state.isLoading
                              ? null
                              : () async {

                                  final idbroj =
                                      idbrojController
                                          .text
                                          .trim();

                                  final sifra =
                                      sifraController
                                          .text
                                          .trim();

                                  if (
                                      idbroj.isEmpty ||
                                      sifra.isEmpty
                                  ) {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      const SnackBar(

                                        content: Text(
                                          'Unesite ID broj i šifru',
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  await auth.login(
                                    idbroj,
                                    sifra,
                                  );

                                  if (
                                      !context.mounted
                                  ) {
                                    return;
                                  }

                                  if (
                                      auth.state
                                          .isAuthenticated
                                  ) {

                                    Navigator.of(
                                      context,
                                    ).pushAndRemoveUntil(

                                      MaterialPageRoute(

                                        builder: (_) =>
                                            const PravnaHomePage(),
                                      ),

                                      (route) => false,
                                    );

                                  } else {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      SnackBar(

                                        content: Text(

                                          auth.state.error ??
                                              'Greška prijave',
                                        ),
                                      ),
                                    );
                                  }
                                },

                      child:
                          auth.state.isLoading

                              ? const SizedBox(

                                  width: 24,
                                  height: 24,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )

                              : const Text(

                                  'Prijava',

                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(

                    '© majstor24.ba',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}