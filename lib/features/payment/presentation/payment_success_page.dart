import 'package:flutter/material.dart';
import 'package:majstor24_app/main.dart';
import 'package:majstor24_app/features/home/presentation/home_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? trx;
  final double? amount;
  final List<dynamic>? packages;

  const PaymentSuccessPage({
    super.key,
    this.trx,
    this.amount,
    this.packages,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();

    // AUTO REDIRECT
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* =========================================
     UI
  ========================================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /* ================= ICON ================= */

              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
              ),

              const SizedBox(height: 20),

              /* ================= TITLE ================= */

              const Text(
                "Plaćanje uspješno",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Vaša transakcija je uspješno završena.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /* ================= DETAILS ================= */

              if (widget.trx != null)
                _infoRow("Transakcija", widget.trx!),

              if (widget.amount != null)
                _infoRow("Iznos", "${widget.amount!.toStringAsFixed(2)} KM"),

              const SizedBox(height: 20),

              /* ================= PACKAGES ================= */

              if (widget.packages != null && widget.packages!.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kupljeni paketi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.packages!.length,
                          itemBuilder: (context, index) {
                            final p = widget.packages![index];

                            return Card(
                              child: ListTile(
                                title: Text(p["naziv"] ?? ""),
                                subtitle: Text(p["opis"] ?? ""),
                                trailing: Text(
                                  "${p["cijena"] ?? ""} KM",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              /* ================= BUTTON ================= */

              ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Idi na početnu"),
              ),

              const SizedBox(height: 10),

              const Text(
                "Automatski povratak za 3 sekunde...",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* =========================================
     HELPER
  ========================================= */

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}