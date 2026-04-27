import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:majstor24_app/features/ticket/presentation/ticket_details_page.dart';
import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/profile/presentation/edit_profile_page.dart';
import '../../package/presentation/payment_webview_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiClient _api = ApiClient();
  final PageController _cardController = PageController(viewportFraction: 0.88);

  bool _loading = true;
  bool _savingRefresh = false;
  String? _error;

  Map<String, dynamic> _profile = {};
  List<dynamic> _cards = [];
  List<dynamic> _tickets = [];
  List<dynamic> _contracts = [];
  List<dynamic> _invoices = [];
  List<dynamic> _purchases = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _deleteCard(int cardId) async {
    try {
      final res = await _api.post(
        "payment/delete_card_mobile.php",
        body: {
          "card_id": cardId,
        },
      );

      if (res is Map && res["success"] == true) {
        await _loadDashboard(silent: true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kartica obrisana")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  Future<void> _loadDashboard({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _savingRefresh = true;
      });
    }

    try {
      final res = await _api.get('profile/dashboard.php');

      if (!mounted) return;

      if (res is Map && res['success'] == true) {
        setState(() {
          _profile = Map<String, dynamic>.from(res['profile'] ?? {});
          _cards = List<dynamic>.from(res['cards'] ?? []);
          _tickets = List<dynamic>.from(res['tickets'] ?? []);
          _contracts = List<dynamic>.from(res['contracts'] ?? []);
          _invoices = List<dynamic>.from(res['invoices'] ?? []);
          _purchases = List<dynamic>.from(res['purchases'] ?? []);
          _error = null;
        });
      } else {
        setState(() {
          _error = (res is Map && res['message'] != null)
              ? res['message'].toString()
              : 'Neuspješno učitavanje profila.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Greška pri učitavanju profila: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _savingRefresh = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialProfile: _profile,
        ),
      ),
    );

    if (!mounted) return;
    await _loadDashboard(silent: true);
  }

  Future<void> _logout() async {
    try {
      await context.read<AuthNotifier>().logout();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout nije uspio.')),
      );
    }
  }

  Future<void> _registerCard() async {
    bool loaderOpened = false;

    try {
      final api = ApiClient();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      loaderOpened = true;

      final res = await api.post("payment/start_register_mobile.php");

      if (loaderOpened && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderOpened = false;
      }

      if (res is! Map || res["success"] != true) {
        throw Exception(
          res is Map ? (res["message"] ?? "Greška") : "Greška",
        );
      }

      final String url = (res["redirectUrl"] ?? "").toString();

      if (url.isEmpty) {
        throw Exception("BANKART_REDIRECT_MISSING");
      }

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebviewModal(url: url),
        ),
      );

      if (result == "success") {
        await _loadDashboard(silent: true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kartica uspješno dodana")),
        );
      } else if (result == "cancel") {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registracija kartice je otkazana")),
        );
      } else if (result == "error") {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registracija kartice nije uspjela")),
        );
      }
    } catch (e) {
      if (loaderOpened && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: () => _loadDashboard(silent: true),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _header(theme),
                                const SizedBox(height: 18),
                                _profileCard(),
                                const SizedBox(height: 18),
                                _cardsSection(),
                                const SizedBox(height: 18),
                                _ticketsSection(),
                                const SizedBox(height: 18),
                                _contractsSection(),
                                const SizedBox(height: 18),
                                _invoicesSection(),
                                const SizedBox(height: 18),
                                // _purchasesSection(),
                                const SizedBox(height: 18),
                                _settingsSection(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Došlo je do greške.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    final fullName =
        '${_text(_profile['firstname'])} ${_text(_profile['lastname'])}'.trim();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moj profil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fullName.isEmpty ? 'Korisnik' : fullName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24,
                color: Color(0x11000000),
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed:
                _savingRefresh ? null : () => _loadDashboard(silent: true),
            icon: _savingRefresh
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );
  }

  Widget _profileCard() {
    final fullName =
        '${_text(_profile['firstname'])} ${_text(_profile['lastname'])}'.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _sectionBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Osnovni podaci',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Uredi'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Ime i prezime', fullName),
          _infoRow('Email', _text(_profile['email'])),
          _infoRow('Telefon', _text(_profile['mobile'])),
          _infoRow('Adresa', _text(_profile['mailingstreet'])),
          _infoRow(
            'PTT i mjesto',
            '${_text(_profile['mailingzip'])} ${_text(_profile['mailingcity'])}'
                .trim(),
          ),
        ],
      ),
    );
  }

  Widget _cardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: 'Moje kartice',
          subtitle: '${_cards.length} registrirane',
          actionLabel: 'Registruj novu karticu',
          onAction: _registerCard,
        ),
        const SizedBox(height: 12),
        if (_cards.isEmpty)
          _emptyBox('Nema registriranih kartica.')
        else
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _cardController,
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = Map<String, dynamic>.from(_cards[index] ?? {});
                return AnimatedBuilder(
                  animation: _cardController,
                  builder: (context, child) {
                    double value = 0;
                    if (_cardController.hasClients &&
                        _cardController.position.hasContentDimensions) {
                      value = (_cardController.page ?? 0) - index;
                    } else {
                      value = _cardController.initialPage - index.toDouble();
                    }

                    final rotation = value * 0.08;
                    final scale = 1 - (value.abs() * 0.06).clamp(0.0, 0.12);

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotation)
                        ..scale(scale),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == _cards.length - 1 ? 0 : 10,
                    ),
                    child: _walletCard(card, index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _walletCard(Map<String, dynamic> card, int index) {
    final brand = _text(card['brand']).isEmpty ? 'Card' : _text(card['brand']);
    final holder = _text(card['cardHolder']).isEmpty
        ? 'CARD HOLDER'
        : _text(card['cardHolder']);
    final masked = _text(card['maskedCard']).isNotEmpty
        ? _text(card['maskedCard'])
        : '**** **** **** ${_text(card['last4'])}';
    final status =
        _text(card['status']).isEmpty ? 'REGISTERED' : _text(card['status']);

    final gradients = [
      const [Color(0xFF10131A), Color(0xFF2B2F3A)],
      const [Color(0xFF14213D), Color(0xFF334EAC)],
      const [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      const [Color(0xFF3C096C), Color(0xFF7B2CBF)],
    ];

    final colors = gradients[index % gradients.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badge(status),
                  const Spacer(),
                  Text(
                    brand.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                masked,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _cardMeta('CARD HOLDER', holder),
                  ),
                  Expanded(
                    child: _cardMeta('LAST 4', _text(card['last4'])),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Deregistracija kartice"),
                        content: const Text("Da li želiš ukloniti karticu?"),
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
                      ),
                    );

                    if (confirm == true) {
                      final id = card['id'];

                      if (id != null) {
                        await _deleteCard(id);
                      }
                    }
                  },
                  child: const Text(
                    "Deregistruj",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contractsSection() {
    return _dataSection(
      title: 'Moji članski paketi',
      subtitle: '${_contracts.length} aktivna zapisa',
      emptyText: 'Nema aktivnih naloga.',
      children: _contracts.map((item) {
        final c = Map<String, dynamic>.from(item ?? {});
        final used = _numText(c['used_units']);
        final total = _numText(c['total_units']);
        final progress = _safeProgress(c['used_units'], c['total_units']);

        return _dashboardItem(
          title: _text(c['subject']).isEmpty ? 'Nalog' : _text(c['subject']),
          leadingIcon: Icons.assignment_outlined,
          rightTop: _statusPill(_text(c['status'])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _miniInfo('Status', _text(c['status'])),
                  _miniInfo('Početak', _formatDate(c['start_date'])),
                  _miniInfo('Važi do', _formatDate(c['due_date'])),
                  _miniInfo('Iskorišteno', '$used / $total'),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE7ECF3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Iskorištenost: ${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _ticketsSection() {
    return _dataSection(
      title: 'Moji tiketi',
      subtitle: '${_tickets.length} tiketa',
      emptyText: 'Nema tiketa.',
      children: _tickets.map((item) {
        final t = Map<String, dynamic>.from(item ?? {});

        return _dashboardItem(
          title: _text(t['title']).isEmpty ? 'Tiket' : _text(t['title']),
          leadingIcon: Icons.support_agent_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _miniInfo('Broj', _text(t['number'])),
                  _miniInfo('Datum', _formatDateTime(t['createdtime'])),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final ticketId = t['id'];
                    final ticketNumber = t['number'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicketDetailsPage(
                          ticketId: ticketId,
                          ticketNumber: ticketNumber,
                        ),
                      ),
                    );
                  },
                  child: const Text("Otvori"),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _invoicesSection() {
    return _dataSection(
      title: 'Moji računi',
      subtitle: '${_invoices.length} računa',
      emptyText: 'Nema računa.',
      children: _invoices.map((item) {
        final inv = Map<String, dynamic>.from(item ?? {});
        return _dashboardItem(
          title: _text(inv['subject']).isEmpty ? 'Račun' : _text(inv['subject']),
          leadingIcon: Icons.receipt_long_outlined,
          rightTop: _amountBox(inv['total']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _miniInfo('Broj', _text(inv['number'])),
                  _miniInfo('Status', _text(inv['status'])),
                  _miniInfo('Ukupno', '${_money(inv['total'])} KM'),
                  _miniInfo('Datum', _formatDate(inv['createdtime'])),
                  if (_text(inv['createdtime']).isNotEmpty)
                    _miniInfo('Kreiran', _formatDateTime(inv['createdtime'])),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _purchasesSection() {
    return _dataSection(
      title: 'Moje kupovine',
      subtitle: '${_purchases.length} kupovina',
      emptyText: 'Nema kupovina.',
      children: _purchases.map((item) {
        final p = Map<String, dynamic>.from(item ?? {});
        return _dashboardItem(
          title:
              _text(p['subject']).isEmpty ? 'Kupovina' : _text(p['subject']),
          leadingIcon: Icons.shopping_bag_outlined,
          rightTop: _amountBox(p['total']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _miniInfo('Broj', _text(p['number'])),
                  _miniInfo('Status', _text(p['status'])),
                  _miniInfo('Ukupno', '${_money(p['total'])} KM'),
                  _miniInfo('Datum', _formatDateTime(p['createdtime'])),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _settingsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _sectionBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Postavke',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _settingsTile(
            icon: Icons.person_outline,
            title: 'Uredi profil',
            subtitle: 'Promjena osnovnih korisničkih podataka',
            onTap: _openEditProfile,
          ),
        ],
      ),
    );
  }

  Widget _dataSection({
    required String title,
    required String subtitle,
    required String emptyText,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _sectionBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 12),
          if (children.isEmpty) _emptyBox(emptyText),
          ...children.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: e,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardItem({
    required String title,
    required IconData leadingIcon,
    required Widget child,
    Widget? rightTop,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(leadingIcon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (rightTop != null) rightTop,
            ],
          ),
          child,
        ],
      ),
    );
  }

Widget _sectionTitle({
  required String title,
  String? subtitle,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FF), // 🔵 background
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A4DFF), // 🔵 naslov
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Color(0xFF1A4DFF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFFF4F4) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: danger ? const Color(0xFFFFD7D7) : const Color(0xFFE6EBF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: danger ? Colors.redAccent : Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: danger ? Colors.redAccent : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _cardMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String status) {
    final normalized = status.toLowerCase();
    Color bg;
    Color fg;

    if (normalized.contains('progress') ||
        normalized.contains('active') ||
        normalized.contains('paid')) {
      bg = const Color(0xFFE8F7EE);
      fg = const Color(0xFF18794E);
    } else if (normalized.contains('pending') ||
        normalized.contains('created')) {
      bg = const Color(0xFFFFF4DD);
      fg = const Color(0xFFA56A00);
    } else {
      bg = const Color(0xFFEFF3F8);
      fg = const Color(0xFF4A5A6A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _amountBox(dynamic amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Text(
        '${_money(amount)} KM',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  BoxDecoration _sectionBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          blurRadius: 24,
          color: Color(0x11000000),
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _numText(dynamic value) {
    if (value == null) return '0';
    if (value is int) return value.toString();
    if (value is double) {
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(2);
    }

    final str = value.toString().trim();
    if (str.isEmpty) return '0';

    final parsed = double.tryParse(str.replaceAll(',', '.'));
    if (parsed == null) return str;
    if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
    return parsed.toStringAsFixed(2);
  }

  String _money(dynamic value) {
    final str = _numText(value);
    return str;
  }

  double _safeProgress(dynamic used, dynamic total) {
    final usedVal = double.tryParse(_numText(used).replaceAll(',', '.')) ?? 0;
    final totalVal = double.tryParse(_numText(total).replaceAll(',', '.')) ?? 0;

    if (totalVal <= 0) return 0;
    return math.max(0, math.min(usedVal / totalVal, 1));
  }

  String _formatDate(dynamic value) {
    final s = _text(value);
    if (s.isEmpty) return '-';

    if (s.length >= 10 && s.contains('-')) {
      final parts = s.substring(0, 10).split('-');
      if (parts.length == 3) {
        return '${parts[2]}.${parts[1]}.${parts[0]}.';
      }
    }

    return s;
  }

  String _formatDateTime(dynamic value) {
    final s = _text(value);
    if (s.isEmpty) return '-';

    if (s.length >= 16 && s.contains(' ')) {
      final parts = s.split(' ');
      final date = _formatDate(parts[0]);
      final time = parts.length > 1 ? parts[1].substring(0, 5) : '';
      return '$date $time';
    }

    return _formatDate(s);
  }
}