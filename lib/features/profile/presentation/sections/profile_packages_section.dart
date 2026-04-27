import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class ProfilePackagesSection extends StatefulWidget {
  const ProfilePackagesSection({super.key});

  @override
  State<ProfilePackagesSection> createState() =>
      _ProfilePackagesSectionState();
}

class _ProfilePackagesSectionState
    extends State<ProfilePackagesSection> {

  final ApiClient _api = ApiClient();

  bool isLoading = true;
  List<dynamic> packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {

    try {

      final data =
          await _api.get('get_service_contracts_mobile.php');

      if (data['success'] == true) {
        packages = data['result'] ?? [];
      } else {
        packages = [];
      }

    } catch (_) {
      packages = [];
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

    if (packages.isEmpty) {
      return const Center(
        child: Text("Nemate aktivnih paketa."),
      );
    }

    return ListView.builder(
      itemCount: packages.length,
      itemBuilder: (context, index) {

        final p = packages[index];

        final double used =
            double.tryParse(p['used_units']?.toString() ?? '0') ?? 0;

        final double total =
            double.tryParse(p['total_units']?.toString() ?? '0') ?? 0;

        final double progress =
            total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

        final int percent =
            total > 0 ? ((used / total) * 100).round() : 0;

        final String startDate =
            p['start_date'] ?? '-';

        final String endDate =
            p['due_date'] ?? '-';

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
                p['subject'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              Text("Status: ${p['status'] ?? ''}"),

              const SizedBox(height: 12),

              Text(
                "${used.toStringAsFixed(2)} / ${total.toStringAsFixed(2)} ($percent%)",
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),

              const SizedBox(height: 14),

              _row("Početak:", startDate),
              _row("Kraj:", endDate),
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