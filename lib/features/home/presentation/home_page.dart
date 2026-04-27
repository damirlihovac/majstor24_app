import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/presentation/login_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../ticket/presentation/ticket_page.dart';
import '../../package/presentation/kupipaket_page.dart';

/* ✅ DODANO */
import '../../../core/network/api_client.dart';
import '../../package/presentation/payment_webview_modal.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "MAJSTOR24",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [

          /* ================= HEADER ================= */

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dobrodošli",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Odaberite akciju",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          /* ================= GRID ================= */

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [

                  _businessCard(
                    icon: Icons.person_outline,
                    title: "Profil",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ),
                      );
                    },
                  ),

                  _businessCard(
                    icon: Icons.workspace_premium_outlined,
                    title: "Kupi paket",
                    onTap: () {
                      Navigator.pushNamed(context, '/kupipaket');
                    },
                  ),

                  _businessCard(
                    icon: Icons.build_outlined,
                    title: "Zatraži asistenciju",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TicketPage(),
                        ),
                      );
                    },
                  ),

 

                  _businessCard(
                    icon: Icons.logout,
                    title: "Odjava",
                    isDanger: true,
                    onTap: () async {

                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text("Odjava"),
                            content: const Text(
                              "Da li se želite odjaviti sa majstor24?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Ne"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Da"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true) return;

                      await context.read<AuthNotifier>().logout();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* =====================================================
     BUSINESS CARD
  ===================================================== */

  Widget _businessCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDanger
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isDanger ? Colors.red : const Color(0xFF1E293B),
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? Colors.red : Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _getSubtitle(title),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(String title) {
    switch (title) {
      case "Profil":
        return "Pregled i izmjena podataka";
      case "Kupi paket":
        return "Aktivirajte usluge";
      case "Zatraži asistenciju":
        return "Kreirajte zahtjev";
      case "Odjava":
        return "Izlaz iz sistema";
      case "Registruj karticu":
        return "Dodajte novu karticu";
      default:
        return "";
    }
  }
}