import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/network/api_client.dart';

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
  late final WebViewController controller;

  final ApiClient _api = ApiClient();

  bool _handledResult = false;

  /* ======================================
     🔥 FINALIZE (ENTERPRISE)
  ====================================== */
  Future<void> _finalizeWithRetry(String trx) async {
    for (int i = 0; i < 3; i++) {
      try {
        final res = await _api.get(
          "payment/finalize_register_mobile.php?trx=$trx",
        );

        debugPrint("FINALIZE RESPONSE: $res");

        if (res["success"] == true) {
          return;
        }
      } catch (e) {
        debugPrint("FINALIZE ERROR: $e");
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /* ======================================
     HANDLE RESULT URL
  ====================================== */
  Future<bool> _handleResultUrl(String url) async {
    debugPrint("WEBVIEW URL: $url");

    if (_handledResult) return true;

    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();

      /* ======================================
         🔥 CUSTOM SCHEME (NAJBITNIJE)
      ====================================== */
      if (url.startsWith("majstor24://")) {
        final status = uri.queryParameters['status'];
        final trx = uri.queryParameters['trx'];

        _handledResult = true;

        if (trx != null && trx.isNotEmpty) {
          await _finalizeWithRetry(trx); // 🔥 FINALIZE
        }

        if (mounted) {
          Navigator.pop(context, status ?? "success");
        }

        return true;
      }

      /* ======================================
         🔥 MOBILE SUCCESS (PACKAGE)
      ====================================== */
      if (path.contains("mobile_success_package.php")) {
        final trx = uri.queryParameters['trx'];

        _handledResult = true;

        if (trx != null && trx.isNotEmpty) {
          await _finalizeWithRetry(trx);
        }

        if (mounted) {
          Navigator.pop(context, "success");
        }

        return true;
      }

      /* ======================================
         🔥 MOBILE SUCCESS (REGISTER)
      ====================================== */
      if (path.contains("mobile_success_register.php")) {
        final trx = uri.queryParameters['trx'];

        _handledResult = true;

        if (trx != null && trx.isNotEmpty) {
          await _finalizeWithRetry(trx);
        }

        if (mounted) {
          Navigator.pop(context, "success");
        }

        return true;
      }

      /* ======================================
         FALLBACK (WEB)
      ====================================== */
      if (path.contains("payment-success")) {
        final trx = uri.queryParameters['trx'];

        _handledResult = true;

        if (trx != null && trx.isNotEmpty) {
          await _finalizeWithRetry(trx);
        }

        if (mounted) Navigator.pop(context, "success");

        return true;
      }

      if (path.contains("payment-error")) {
        _handledResult = true;
        if (mounted) Navigator.pop(context, "error");
        return true;
      }

      if (path.contains("payment-cancel")) {
        _handledResult = true;
        if (mounted) Navigator.pop(context, "cancel");
        return true;
      }

      /* ======================================
         🔥 EXTRA (AKO TRX U URL-u)
      ====================================== */
      if (uri.queryParameters.containsKey("trx") &&
          uri.queryParameters.containsKey("status")) {
        final trx = uri.queryParameters['trx'];
        final status = uri.queryParameters['status'];

        _handledResult = true;

        if (trx != null && trx.isNotEmpty) {
          await _finalizeWithRetry(trx);
        }

        if (mounted) {
          Navigator.pop(context, status ?? "success");
        }

        return true;
      }
    } catch (e) {
      debugPrint("WEBVIEW URL PARSE ERROR: $e");
    }

    return false;
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          /* ======================================
             🔥 NAVIGATION INTERCEPT
          ====================================== */
          onNavigationRequest: (request) async {
            final url = request.url;

            final handled = await _handleResultUrl(url);

            if (handled) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onPageStarted: (url) async {
            await _handleResultUrl(url);
          },

          onPageFinished: (url) async {
            await _handleResultUrl(url);
          },

          onUrlChange: (change) async {
            final url = change.url ?? "";
            debugPrint("URL CHANGE: $url");

            await _handleResultUrl(url);
          },

          onWebResourceError: (error) {
            debugPrint("WEBVIEW ERROR: ${error.description}");
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
      body: WebViewWidget(controller: controller),
    );
  }
}