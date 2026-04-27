import 'package:flutter/material.dart';
import 'package:majstor24_app/main.dart';
import 'package:majstor24_app/features/home/presentation/home_page.dart';

class RequestSuccessPage extends StatefulWidget {
  final String? ticketWsId;
  final String trx;

  const RequestSuccessPage({
    super.key,
    required this.trx,
    this.ticketWsId,
  });

  @override
  State<RequestSuccessPage> createState() => _RequestSuccessPageState();
}

class _RequestSuccessPageState extends State<RequestSuccessPage> {

  @override
  void initState() {
    super.initState();

    // 🔥 AUTO REDIRECT NA HOME
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uspješno")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: 12),
            const Text(
              "Zahtjev je zaprimljen.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text("TRX: ${widget.trx}"),
            const SizedBox(height: 6),
            Text("Ticket: ${widget.ticketWsId ?? '-'}"),
            const Spacer(),

            // opcionalno dugme (može ostati)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Nazad na početnu"),
              ),
            )
          ],
        ),
      ),
    );
  }
}