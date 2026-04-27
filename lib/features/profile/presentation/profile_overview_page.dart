import 'package:flutter/material.dart';
import '../data/profile_api.dart';
import '../data/profile_models.dart';
import 'widgets/profile_section_card.dart';

class ProfileOverviewPage extends StatefulWidget {
  final ProfileApi api;

  const ProfileOverviewPage({
    super.key,
    required this.api,
  });

  @override
  State<ProfileOverviewPage> createState() => _ProfileOverviewPageState();
}

class _ProfileOverviewPageState extends State<ProfileOverviewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _loading = true;
  String? _error;

  List<PaymentCardItem> _cards = [];
  List<ServiceContractItem> _accounts = [];
  List<InvoiceItem> _invoices = [];
  List<PurchaseItem> _purchases = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.api.getCards(),
        widget.api.getAccounts(),
        widget.api.getInvoices(),
        widget.api.getPurchases(),
      ]);

      setState(() {
        _cards = results[0] as List<PaymentCardItem>;
        _accounts = results[1] as List<ServiceContractItem>;
        _invoices = results[2] as List<InvoiceItem>;
        _purchases = results[3] as List<PurchaseItem>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildCardsTab() {
    if (_cards.isEmpty) {
      return const Center(child: Text('Nema registrovanih kartica'));
    }

    return ListView.builder(
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final item = _cards[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: Text(item.maskedCard.isNotEmpty ? item.maskedCard : 'Kartica'),
            subtitle: Text('${item.brand} • ${item.cardHolder}'),
            trailing: Text(item.status),
          ),
        );
      },
    );
  }

  Widget _buildAccountsTab() {
    if (_accounts.isEmpty) {
      return const Center(child: Text('Nema aktivnih naloga'));
    }

    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final item = _accounts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined),
            title: Text(item.subject),
            subtitle: Text('Status: ${item.status}\nVaži do: ${item.dueDate}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildInvoicesTab() {
    if (_invoices.isEmpty) {
      return const Center(child: Text('Nema računa'));
    }

    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final item = _invoices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(item.number.isNotEmpty ? item.number : item.subject),
            subtitle: Text('${item.subject}\n${item.createdTime}'),
            trailing: Text('${item.total.toStringAsFixed(2)} KM'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildPurchasesTab() {
    if (_purchases.isEmpty) {
      return const Center(child: Text('Nema kupovina'));
    }

    return ListView.builder(
      itemCount: _purchases.length,
      itemBuilder: (context, index) {
        final item = _purchases[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text(item.number.isNotEmpty ? item.number : item.subject),
            subtitle: Text('${item.subject}\nStatus: ${item.status}'),
            trailing: Text('${item.total.toStringAsFixed(2)} KM'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileSectionCard(
          title: 'Moje kartice',
          subtitle: 'Registrovane kartice za plaćanje',
          icon: Icons.credit_card,
          onTap: () => _tabController.animateTo(0),
        ),
        ProfileSectionCard(
          title: 'Moji nalozi',
          subtitle: 'Servisni ugovori i aktivni nalozi',
          icon: Icons.assignment_turned_in_outlined,
          onTap: () => _tabController.animateTo(1),
        ),
        ProfileSectionCard(
          title: 'Moji računi',
          subtitle: 'Lista računa iz CRM-a',
          icon: Icons.receipt_long,
          onTap: () => _tabController.animateTo(2),
        ),
        ProfileSectionCard(
          title: 'Moje kupovine',
          subtitle: 'Historija kupovina i narudžbi',
          icon: Icons.shopping_bag_outlined,
          onTap: () => _tabController.animateTo(3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Kartice'),
              Tab(text: 'Nalozi'),
              Tab(text: 'Računi'),
              Tab(text: 'Kupovine'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Greška: $_error',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCardsTab(),
                      _buildAccountsTab(),
                      _buildInvoicesTab(),
                      _buildPurchasesTab(),
                    ],
                  ),
      ),
    );
  }
}