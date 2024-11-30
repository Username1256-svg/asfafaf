import 'dart:io';
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
      );

    _startLocalServer().then((_) {
      // После запуска сервера загружаем страницу
      _controller.loadRequest(Uri.parse('http://localhost:8080/assets/index.html'));
    });
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
      if (request.uri.path == '/assets/index.html') {
        await serveFile(request, 'assets/index.html');
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    });
  }

  // Метод для чтения файла из assets
  Future<void> serveFile(HttpRequest request, String filePath) async {
    try {
      final data = await rootBundle.loadString(filePath);
      request.response.headers.contentType = ContentType.html;
      request.response.write(data);
    } catch (e) {
      request.response.statusCode = HttpStatus.notFound;
    } finally {
      await request.response.close();
    }
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
