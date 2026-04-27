import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewModal extends StatefulWidget {
  final String url;

  const PaymentWebviewModal({
    super.key,
    required this.url,
  });

  @override
  State<PaymentWebviewModal> createState() => _PaymentWebviewModalState();
}

class _PaymentWebviewModalState extends State<PaymentWebviewModal> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      /* =====================================
         🔥 NAVIGATION HANDLER (CORE LOGIC)
      ===================================== */
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            print("WEBVIEW NAV: $url");

            /* ===============================
               ✅ DEEP LINK (NAJBITNIJE)
            =============================== */
            if (url.startsWith("majstor24://")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters['status'];

              if (mounted) {
                Navigator.pop(context, status ?? "success");
              }

              return NavigationDecision.prevent;
            }

            /* ===============================
               ✅ SUCCESS (PACKAGE + TICKET)
            =============================== */
            if (url.contains("mobile_success_")) {
              if (mounted) {
                Navigator.pop(context, "success");
              }

              return NavigationDecision.prevent;
            }

            /* ===============================
               ❌ ERROR / CANCEL
            =============================== */
            if (url.contains("error") || url.contains("cancel")) {
              if (mounted) {
                Navigator.pop(context, "error");
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          /* =====================================
             🔥 ANDROID FIX (URL CHANGE)
          ===================================== */
          onUrlChange: (change) {
            final url = change.url ?? "";

            print("URL CHANGE: $url");

            if (url.startsWith("majstor24://")) {
              final uri = Uri.parse(url);
              final status = uri.queryParameters['status'];

              if (mounted) {
                Navigator.pop(context, status ?? "success");
              }
            }

            if (url.contains("mobile_success_")) {
              if (mounted) {
                Navigator.pop(context, "success");
              }
            }
          },
        ),
      )

      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plaćanje"),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}