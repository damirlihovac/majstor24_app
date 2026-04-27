import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class ProfileAccountsSection extends StatefulWidget {
  const ProfileAccountsSection({super.key});

  @override
  State<ProfileAccountsSection> createState() =>
      _ProfileAccountsSectionState();
}

class _ProfileAccountsSectionState
    extends State<ProfileAccountsSection> {

  final ApiClient _api = ApiClient();

  bool isLoading = true;
  List<dynamic> tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // ================= LOAD TICKETS =================

  Future<void> _loadTickets() async {

    try {

      final data =
          await _api.get('get_tickets_mobile.php');

      if (data['success'] == true) {
        tickets = data['result'] ?? [];
      } else {
        tickets = [];
      }

    } catch (_) {

      tickets = [];

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

    if (tickets.isEmpty) {
      return const Center(
        child: Text("Nemate otvorenih naloga."),
      );
    }

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {

        final t = tickets[index];

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
                t['number'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              Text(t['title'] ?? ''),

              const SizedBox(height: 10),

              _row("Status:", t['status'] ?? ''),
              _row("Datum:", t['createdtime'] ?? ''),

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