import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BankartWebView extends StatefulWidget {
  final String url;

  const BankartWebView({super.key, required this.url});

  @override
  State<BankartWebView> createState() => _BankartWebViewState();
}

class _BankartWebViewState extends State<BankartWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plaćanje")),
      body: WebViewWidget(controller: _controller),
    );
  }
}