import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  String _errors = ''; // Строка для отображения ошибок

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
      ..loadRequest(
        Uri.parse('http://localhost:8080/assets/index.html'), // Используем локальный сервер
      );

    _startLocalServer();
  }

  // Метод для обработки сообщений от JavaScript
  void _handleJSMessage(String message) {
    setState(() {
      _errors = message; // Отображаем ошибки на экране
    });
  }

  // Старт локального HTTP-сервера
  Future<void> _startLocalServer() async {

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    server.listen((HttpRequest request) async {
      final filePath = 'assets/index.html'; // Путь к вашему файлу
      final file = File(filePath);

      if (await file.exists()) {
        request.response.headers.contentType = ContentType.html;
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
      await request.response.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView Page')),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          if (_errors.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                'JavaScript Error: $_errors',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
