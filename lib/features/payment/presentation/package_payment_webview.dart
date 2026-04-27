import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PackagePaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String merchantTrxId;
  final List<Map<String, dynamic>> korpa;

  const PackagePaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.merchantTrxId,
    required this.korpa,
  });

  @override
  State<PackagePaymentWebView> createState() =>
      _PackagePaymentWebViewState();
}

class _PackagePaymentWebViewState extends State<PackagePaymentWebView> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(

          onNavigationRequest: (request) {

            final url = request.url;

            // Android deep link iz bankart-return.php
            if (url.startsWith("majstor24://payment/success")) {

              Navigator.pop(context, {
                "success": true,
                "trx": widget.merchantTrxId
              });

              return NavigationDecision.prevent;
            }

            // Web fallback
            if (url.contains("/uspjesno")) {

              Navigator.pop(context, {
                "success": true,
                "trx": widget.merchantTrxId
              });

              return NavigationDecision.prevent;
            }

            // error fallback
            if (url.contains("/greska") || url.contains("/otkazano")) {

              Navigator.pop(context, {
                "success": false
              });

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plaćanje karticom"),
      ),

      body: WebViewWidget(controller: controller),
    );
  }
}
Kako Flutter koristi rezultat

Kada WebView završi:

final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PackagePaymentWebView(
      paymentUrl: redirectUrl,
      merchantTrxId: merchantTrxId,
      korpa: korpa,
    ),
  ),
);

if(result["success"] == true){

  final tx = result["trx"];

  await verifyPayment(tx);

}