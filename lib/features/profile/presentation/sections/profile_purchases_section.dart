import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class ProfilePurchasesSection extends StatefulWidget {
  const ProfilePurchasesSection({super.key});

  @override
  State<ProfilePurchasesSection> createState() =>
      _ProfilePurchasesSectionState();
}

class _ProfilePurchasesSectionState
    extends State<ProfilePurchasesSection> {

  final ApiClient _api = ApiClient();

  bool isLoading = true;
  List<dynamic> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {

    try {

      final data =
          await _api.get('get_invoices_mobile.php');

      if (data['success'] == true) {
        invoices = data['result'] ?? [];
      } else {
        invoices = [];
      }

    } catch (_) {
      invoices = [];
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (invoices.isEmpty) {
      return const Center(
        child: Text("Nemate računa."),
      );
    }

    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {

        final inv = invoices[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              )
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                inv['number'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              Text(inv['subject'] ?? ''),

              const SizedBox(height: 10),

              _row("Status:", inv['status'] ?? ''),
              _row("Datum:", inv['createdtime'] ?? ''),

              _row(
                "Iznos:",
                "${(inv['total'] ?? 0).toString()} KM",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),

      child: Row(
        children: [

          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}