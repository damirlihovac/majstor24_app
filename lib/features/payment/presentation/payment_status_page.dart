import 'dart:async';
import 'dart:convert';
import 'package:majstor24_app/features/auth/presentation/auth_gate.dart';
import 'package:majstor24_app/features/home/presentation/home_page.dart';
import 'package:majstor24_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum PaymentType { ticket, package }

class PaymentStatusPage extends StatefulWidget {
  final String trx;
  final PaymentType type;

  const PaymentStatusPage({
    super.key,
    required this.trx,
    required this.type,
  });

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {

  String status = "PROCESSING";
  String? entityId;

  Timer? _timer;
  bool _redirected = false;

  /* ======================================
     ENDPOINT RESOLVER
  ====================================== */
  String get _endpoint {
    switch (widget.type) {
      case PaymentType.ticket:
        return "https://majstor24.ba/api/payment/check_ticket_status.php";
      case PaymentType.package:
        return "https://majstor24.ba/api/payment/check_package_status.php";
    }
  }

  /* ======================================
     POLLING
  ====================================== */
  Future<void> _checkStatus() async {
    try {
      final res = await http.get(
        Uri.parse("$_endpoint?trx=${widget.trx}"),
      );

      final data = jsonDecode(res.body);

      if (data["success"] != true) return;

      setState(() {
        status = data["status"];
        entityId =
            data["ticket_id"] ??
            data["opportunity_id"];
      });

      /* STOP POLLING */
      if (status == "DONE" || status == "ERROR") {
        _timer?.cancel();
      }

      /* AUTO REDIRECT */
      if (status == "DONE" && !_redirected) {
        _redirected = true;

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

navigatorKey.currentState?.pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => HomePage()),
  (route) => false,
);
        });
      }

    } catch (_) {}
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkStatus();
    });
  }

  @override
  void initState() {
    super.initState();

    _checkStatus();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /* ======================================
     UI
  ====================================== */
  @override
  Widget build(BuildContext context) {

    final isDone = status == "DONE";
    final isError = status == "ERROR";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Status"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              isDone
                  ? Icons.check_circle
                  : isError
                      ? Icons.error
                      : Icons.hourglass_bottom,
              color: isDone
                  ? Colors.green
                  : isError
                      ? Colors.red
                      : Colors.orange,
              size: 80,
            ),

            const SizedBox(height: 20),

            Text(
              isDone
                  ? "Uplata uspješna"
                  : isError
                      ? "Greška"
                      : "Obrada u toku...",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (entityId != null)
              Text(
                widget.type == PaymentType.ticket
                    ? "Ticket: $entityId"
                    : "Opportunity: $entityId",
              ),

            const SizedBox(height: 20),

            Text(
              "TRX: ${widget.trx}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            if (isDone)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
onPressed: () {
navigatorKey.currentState?.pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => HomePage(),
  ),
  (route) => false,
);},
                  child: const Text("Nazad na početnu"),
                ),
              ),

            if (isError)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Nazad"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}