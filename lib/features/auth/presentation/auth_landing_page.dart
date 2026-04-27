import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart'; // napravi ako već nemaš

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🔹 Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/auth_bg.jpg', // dodaj svoju sliku
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Dark overlay
          Container(
            color: Colors.black.withOpacity(0.55),
          ),

          // 🔹 Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const SizedBox(height: 40),

                  // 🔹 Logo / title
                  Column(
                    children: const [
                      Text(
                        "majstor24",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Brza kućna asistencija",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  // 🔹 Buttons
                  Column(
                    children: [

                      // Registracija
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Registracija",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Prijava
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Prijava",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}