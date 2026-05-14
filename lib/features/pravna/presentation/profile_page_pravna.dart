import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/pravna/presentation/company_profile_page.dart';

class ProfilePagePravna extends StatefulWidget {
  const ProfilePagePravna({super.key});

  @override
  State<ProfilePagePravna> createState() => _ProfilePagePravnaState();
}

class _ProfilePagePravnaState extends State<ProfilePagePravna> {

  final ApiClient _api = ApiClient();

  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  Map<String, dynamic> _company = {};
  List _contracts = [];
  List _invoices = [];
  List _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool silent = false}) async {

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _refreshing = true);
    }

    try {

      final company = await _api.get('pravna/api/get_company_profile.php');
      final contracts = await _api.get('pravna/api/get_service_contracts_company.php');
      final invoices = await _api.get('pravna/api/get_invoices_company.php');
      final tickets = await _api.get('pravna/api/get_salesorders_pravna.php');

      if (!mounted) return;

      setState(() {
       _company = company is Map
    ? Map<String, dynamic>.from(company)
    : {};
        _contracts = contracts is List ? contracts : [];
        _invoices = invoices is List ? invoices : [];
        _tickets = tickets is List ? tickets : [];
      });

    } catch (e) {
      _error = 'Greška: $e';
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _refreshing = false;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthNotifier>().logout();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : RefreshIndicator(
                    onRefresh: () => _loadDashboard(silent: true),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                _header(),

                                const SizedBox(height: 20),

                                _companyCard(),

                                const SizedBox(height: 20),

                                _contractsSection(),

                                const SizedBox(height: 20),

                                _ticketsSection(),

                                const SizedBox(height: 20),

                                _invoicesSection(),

                                const SizedBox(height: 20),

                                _settingsSection(),

                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Profil firme",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _text(_company['accountname'] ?? _company['company_name']),
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: _refreshing ? null : _loadDashboard,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _companyCard() {
    return _sectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Podaci firme",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          _infoRow("Naziv", _text(_company['accountname'])),
          _infoRow("Email", _text(_company['email1'])),
          _infoRow("Telefon", _text(_company['phone'])),
          _infoRow("Adresa", _text(_company['bill_street'])),

        ],
      ),
    );
  }

  Widget _contractsSection() {
    return _dataSection(
      title: "Ugovori",
      data: _contracts,
      icon: Icons.assignment_outlined,
    );
  }

  Widget _ticketsSection() {
    return _dataSection(
      title: "Narudžbe",
      data: _tickets,
      icon: Icons.support_agent_outlined,
    );
  }

  Widget _invoicesSection() {
    return _dataSection(
      title: "Fakture",
      data: _invoices,
      icon: Icons.receipt_long_outlined,
    );
  }

  Widget _settingsSection() {
    return _sectionBox(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Nazad na profil firme"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Odjava"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _dataSection({
    required String title,
    required List data,
    required IconData icon,
  }) {
    return _sectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          if (data.isEmpty)
            const Text("Nema podataka")
          else
            ...data.map((e) => ListTile(
                  leading: Icon(icon),
                  title: Text(_text(e['subject'])),
                )),

        ],
      ),
    );
  }

  Widget _sectionBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            blurRadius: 24,
            color: Color(0x11000000),
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label),
          ),
          Expanded(child: Text(value.isEmpty ? "-" : value)),
        ],
      ),
    );
  }

  String _text(dynamic v) => v?.toString() ?? "";
}