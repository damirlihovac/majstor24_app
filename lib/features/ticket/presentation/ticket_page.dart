import 'package:majstor24_app/core/auth/auth_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:majstor24_app/core/auth/session_manager.dart';
import 'request_form_widget.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {

  String userAddress = '';
  String userZip = '';
  String userCity = '';
  bool isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {

    try {

      final storage = AuthStorage();

      final street = await storage.getMailingStreet();
      final zip = await storage.getMailingZip();
      final city = await storage.getMailingCity();

      if (!mounted) return;

      setState(() {
        userAddress = street ?? '';
        userZip = zip ?? '';
        userCity = city ?? '';
        isLoadingAddress = false;
      });

    } catch (_) {

      if (!mounted) return;

      setState(() {
        userAddress = '';
        userZip = '';
        userCity = '';
        isLoadingAddress = false;
      });
    }
  }

  bool get _hasAddress {

    final parts = [
      userAddress,
      "$userZip $userCity".trim(),
    ].where((e) => e.trim().isNotEmpty).toList();

    return parts.isNotEmpty;
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
          "Zatraži asistenciju",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: isLoadingAddress
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [

                  /* ================= HEADER ================= */

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
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
                          "Kreiranje zahtjeva",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Unesite detalje za asistenciju",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /* ================= CONTENT ================= */

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// ADRESA BLOK
                          if (_hasAddress) ...[

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.location,
                                      size: 18,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        children: [

                                          if (userAddress.isNotEmpty) ...[
                                            const TextSpan(text: "Adresa: "),
                                            TextSpan(
                                              text: "$userAddress\n",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],

                                          if (userZip.isNotEmpty) ...[
                                            const TextSpan(text: "PTT: "),
                                            TextSpan(
                                              text: "$userZip\n",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],

                                          if (userCity.isNotEmpty) ...[
                                            const TextSpan(text: "Mjesto: "),
                                            TextSpan(
                                              text: userCity,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],

                          /// SECTION HEADER
                          const Text(
                            "DETALJI ZAHTJEVA",
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// FORM CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const RequestFormWidget(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formattedAddress() {

    final parts = [
      userAddress,
      "$userZip $userCity".trim(),
    ].where((e) => e.trim().isNotEmpty).toList();

    return parts.join(", ");
  }
}