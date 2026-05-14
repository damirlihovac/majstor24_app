import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebviewPage
    extends StatefulWidget {

  final String paymentUrl;

  const PaymentWebviewPage({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebviewPage>
      createState() =>
          _PaymentWebviewPageState();
}

class _PaymentWebviewPageState
    extends State<PaymentWebviewPage> {

  late final WebViewController
      controller;

@override
void initState() {

  super.initState();

  controller = WebViewController();

  debugPrint(
    "INITIAL PAYMENT URL: ${widget.paymentUrl}",
  );

  controller

  ..setJavaScriptMode(
  JavaScriptMode.unrestricted,
)

..enableZoom(true)

..setBackgroundColor(
  Colors.white,
)

..setUserAgent(
  "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36",
)

    ..setNavigationDelegate(

      NavigationDelegate(

        onNavigationRequest: (request) {

          final url = request.url;

          debugPrint(
            "WEBVIEW NAVIGATION URL: $url",
          );

 if (

    url.contains("bankart-return") ||
    url.contains("uspjesno") ||
    url.contains("success") ||
    url.contains("approved") ||

    (
      url.contains("payment") &&
      url.contains("return")
    )

) {

  debugPrint(
    "PAYMENT SUCCESS DETECTED",
  );

  Navigator.pop(
    context,
    true,
  );

  return NavigationDecision.prevent;
}

if (

    url.contains("otkazano") ||
    url.contains("cancel") ||
    url.contains("greska") ||
    url.contains("error") ||
    url.contains("declined")

) {

  debugPrint(
    "PAYMENT CANCEL DETECTED",
  );

  Navigator.pop(
    context,
    false,
  );

  return NavigationDecision.prevent;
}

          if (

              url.contains("otkazano") ||
              url.contains("cancel") ||
              url.contains("greska") ||
              url.contains("error") ||
              url.contains("declined")

          ) {

            debugPrint(
              "PAYMENT CANCEL DETECTED",
            );

         Navigator.pop(
  context,
  false,
);

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },

        onPageStarted: (url) {

          debugPrint(
            "PAGE STARTED: $url",
          );
        },

        onPageFinished: (url) {

          debugPrint(
            "PAGE FINISHED: $url",
          );
        },
      ),
    )

    ..loadRequest(
      Uri.parse(
        widget.paymentUrl,
      ),
    );
}

 
  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Kartično plaćanje",
        ),
        backgroundColor:
            Colors.red,
      ),

      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}