import 'dart:async';
import 'package:flutter/material.dart';
import '../../payment/application/payment_status_service.dart';
import '../../payment/domain/payment_status_model.dart';

enum PaymentFlowType { package, ticket, card }

class PaymentResultPage extends StatefulWidget {
  final String trx;
  final PaymentFlowType type;
  final String? title;

  const PaymentResultPage({
    super.key,
    required this.trx,
    required this.type,
    this.title,
  });

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  PaymentStatus? status;
  Timer? _timer;
  bool _finished = false; // 🔥 SPRJEČAVA DUPLI NAVIGATOR

  Future<void> _check() async {
    try {
      PaymentStatus result;

      switch (widget.type) {
        case PaymentFlowType.package:
          result = await PaymentStatusService.checkPackage(widget.trx);
          break;
        case PaymentFlowType.ticket:
          result = await PaymentStatusService.checkTicket(widget.trx);
          break;
        case PaymentFlowType.card:
          result = await PaymentStatusService.checkCard(widget.trx);
          break;
      }

      if (!mounted) return;

      setState(() => status = result);

      /* ======================================
         🔥 KLJUČNO – AUTO ZAVRŠETAK
      ====================================== */
      if ((result.isDone || result.isError) && !_finished) {
        _finished = true;
        _timer?.cancel();

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          Navigator.popUntil(context, (route) => route.isFirst);
        });
      }
    } catch (e) {
      debugPrint("STATUS ERROR: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _check();

    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _check(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = status;

    final isDone = s?.isDone == true;
    final isError = s?.isError == true;

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
              size: 80,
              color: isDone
                  ? Colors.green
                  : isError
                      ? Colors.red
                      : Colors.orange,
            ),

            const SizedBox(height: 20),

            Text(
              isDone
                  ? (widget.title ?? "Uspješno")
                  : isError
                      ? "Greška"
                      : "Obrada u toku...",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "TRX: ${widget.trx}",
              style: const TextStyle(fontSize: 12),
            ),

            if (s?.entityId != null)
              Text("ID: ${s!.entityId}"),

            const SizedBox(height: 40),

            /* ======================================
               MANUAL BUTTON (fallback)
            ====================================== */

            if (isDone)
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                child: const Text("Nazad na početnu"),
              ),

            if (isError)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Nazad"),
              ),
          ],
        ),
      ),
    );
  }
}