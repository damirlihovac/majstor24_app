import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/presentation/role_selection_page.dart';

import 'company_profile_page.dart';
import 'ugovori_page.dart';
import 'fakture_page.dart';
import 'naruci_asistenciju_page.dart';

class PravnaHome extends StatelessWidget {
  const PravnaHome({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthNotifier>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleSelectionPage(),
      ),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "business-majstor24",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Dobrodošli",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Odaberite opciju (pravna_home.dart)",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),

              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,

                children: [

                  dashboardCard(
                    context,
                    Icons.business_outlined,
                    "Profil firme",
                    "Podaci kompanije",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                           const CompanyProfilePage(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    context,
                    Icons.description_outlined,
                    "Ugovori",
                    "Pregled paketa",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                           const UgovoriPage(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    context,
                    Icons.build_outlined,
                    "Asistencija",
                    "Kreiraj zahtjev",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                           const NaruciAsistencijuPage(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    context,
                    Icons.logout,
                    "Odjava",
                    "Izlaz iz sistema",
                    () {
                      _logout(context);
                    },
                    danger: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),

      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Padding(
          padding: const EdgeInsets.all(14),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                size: 34,
                color: danger
                    ? Colors.red
                    : const Color(
                        0xFF1E293B,
                      ),
              ),

              const SizedBox(height:12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                  color: danger
                      ? Colors.red
                      : Colors.black87,
                ),
              ),

              const SizedBox(height:6),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize:11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}