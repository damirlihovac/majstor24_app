import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_gate.dart';
import '../../../core/role_manager.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _selectRole(
    BuildContext context,
    String role,
  ) async {
    RoleManager.setRole(role);

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'role',
      role,
    );

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AuthGate(),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/pozadina.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(
                .08,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),

                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 460,
                  ),

                  child: Column(
                    children: [

                      const SizedBox(
                        height: 10,
                      ),

                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          38,
                        ),

                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(
                            sigmaX: 18,
                            sigmaY: 18,
                          ),

                          child: Container(
                            height: 210,
                            width: 210,

                            padding:
                                const EdgeInsets
                                    .all(24),

                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(
                                      .82),

                              border: Border.all(
                                color:
                                    Colors.white,
                                width: 1.5,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                48,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 32,
                                  offset:
                                      const Offset(
                                    0,
                                    10,
                                  ),
                                  color: Colors
                                      .black
                                      .withOpacity(
                                    .05,
                                  ),
                                )
                              ],
                            ),

                            child: Image.asset(
                              "assets/images/majstor24.png",
                              fit:
                                  BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 32,
                      ),

                      const Text(
                        "Trebam majstor24 za",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w800,
                          color: Color(
                            0xff111827,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      _roleCard(
                        context,
                        title:
                            "Domaćinstvo",
                        role:
                            "fizicka",
                        icon:
                            Icons.home_outlined,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      _roleCard(
                        context,
                        title:
                            "Kompanija",
                        role:
                            "pravna",
                        icon:
                            Icons.business_outlined,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      _roleCard(
                        context,
                        title:
                            "Izvršilac",
                        role:
                            "izvrsilac",
                        icon:
                            Icons.engineering_outlined,
                      ),

                      const SizedBox(
                        height: 32,
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String role,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () =>
          _selectRole(
            context,
            role,
          ),

      borderRadius:
          BorderRadius.circular(
        26,
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          26,
        ),

        child: BackdropFilter(
          filter:
              ImageFilter.blur(
            sigmaX: 14,
            sigmaY: 14,
          ),

          child: Container(
            height: 70,

            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
            ),

            decoration:
                BoxDecoration(
              color: const Color(
                0xffF3F4F6,
              ),

              border: Border.all(
                color: Colors.white,
                width: 1.3,
              ),

              borderRadius:
                  BorderRadius.circular(
                26,
              ),

              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset:
                      const Offset(
                    0,
                    6,
                  ),
                  color: Colors.black
                      .withOpacity(
                    .05,
                  ),
                )
              ],
            ),

            child: Row(
              children: [

                Icon(
                  icon,
                  size: 26,
                  color: const Color(
                    0xff111827,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child: Text(
                    title,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color:
                      Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}