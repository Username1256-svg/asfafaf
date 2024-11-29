import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          _handleJSMessage(message.message);
        },
      )
      ..loadFlutterAsset('assets/js/index.html');
  }

  void _handleJSMessage(String message) {
    if (message == 'showAd') {
      _showAd(); // Реализация показа рекламы
    } else if (message == 'shareApp') {
      _shareApp();
    } else if (message.startsWith('setOrientation:')) {
      _setOrientation(message.split(':')[1]);
    }
  }

  void _showAd() {
    // Реализация показа рекламы
  }

  void _shareApp() {
    // Шеринг через Flutter package (например, `share_plus`)
  }

  void _setOrientation(String orientation) {
    if (orientation == 'portrait') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else if (orientation == 'landscape') {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView Page')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
