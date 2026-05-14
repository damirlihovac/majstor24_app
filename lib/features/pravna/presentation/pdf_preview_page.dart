import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfPreviewPage extends StatelessWidget {

  final String url;

  const PdfPreviewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Pregled ugovora")),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}