import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;

  const PdfViewerPage({
    super.key,
    required this.url,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final WebViewController controller;

  bool _loading = true;
  bool _downloading = false;

  String? _localPath;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /* ==========================================
     DOWNLOAD PDF
  ========================================== */

  Future<void> _downloadPdf() async {
    try {
      setState(() => _downloading = true);

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/uplatnica_${DateTime.now().millisecondsSinceEpoch}.pdf";

      await Dio().download(widget.url, path);

      setState(() {
        _localPath = path;
        _downloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF sačuvan: $path")),
      );

    } catch (e) {
      setState(() => _downloading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška download: $e")),
      );
    }
  }

  /* ==========================================
     SHARE PDF
  ========================================== */

  Future<void> _sharePdf() async {
    try {
      if (_localPath == null) {
        await _downloadPdf();
      }

      if (_localPath != null) {
        await Share.shareXFiles([XFile(_localPath!)]);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška share: $e")),
      );
    }
  }

  /* ==========================================
     UI
  ========================================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uplatnica"),
        actions: [

          // 🔽 DOWNLOAD
          IconButton(
            icon: _downloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _downloading ? null : _downloadPdf,
          ),

          // 📤 SHARE
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}