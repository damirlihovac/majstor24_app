import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BankartWebViewScreen extends StatefulWidget {
  final String url;

  const BankartWebViewScreen({super.key, required this.url});

  @override
  State<BankartWebViewScreen> createState() => _BankartWebViewScreenState();
}

class _BankartWebViewScreenState extends State<BankartWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Deep link presretanje
            if (request.url.startsWith('majstor24://payment-result')) {
              Navigator.pop(context); // zatvori WebView
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plaćanje')),
      body: WebViewWidget(controller: _controller),
    );
  }
}