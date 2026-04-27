import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class ProfileOrdersSection extends StatefulWidget {
  const ProfileOrdersSection({super.key});

  @override
  State<ProfileOrdersSection> createState() =>
      _ProfileOrdersSectionState();
}

class _ProfileOrdersSectionState
    extends State<ProfileOrdersSection> {

  final ApiClient _api = ApiClient();

  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // ================= LOAD ORDERS =================

  Future<void> _loadOrders() async {

    try {

      final data =
          await _api.get('get_salesorders_mobile.php');

      if (data['success'] == true) {
        orders = data['result'] ?? [];
      } else {
        orders = [];
      }

    } catch (_) {

      orders = [];

    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text("Nemate narudžbi."),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {

        final o = orders[index];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                o['number'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              Text(o['subject'] ?? ''),

              const SizedBox(height: 10),

              _row("Status:", o['status'] ?? ''),
              _row("Datum:", o['createdtime'] ?? ''),

              _row(
                "Iznos:",
                "${(o['total'] ?? 0).toString()} KM",
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