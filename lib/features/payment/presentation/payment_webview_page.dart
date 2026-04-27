import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String url;

  const PaymentWebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<PaymentWebViewPage> createState() =>
      _PaymentWebViewPageState();
}

class _PaymentWebViewPageState
    extends State<PaymentWebViewPage> {

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setNavigationDelegate(

        NavigationDelegate(

          onNavigationRequest: (request) {

            /// success redirect iz Bankart return stranice
            if (request.url.contains("mobile_success_ticket.php")) {

              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            /// deep link fallback
            if (request.url.startsWith("majstor24://payment-result")) {

              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onPageStarted: (url) {

            if (mounted) {
              setState(() => _loading = true);
            }

          },

          onPageFinished: (url) {

            if (mounted) {
              setState(() => _loading = false);
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

      body: Stack(

        children: [

          WebViewWidget(controller: _controller),

          if (_loading)
            const Center(
              child: CircularProgressIndicator(),
            ),

        ],

      ),
    );
  }
}