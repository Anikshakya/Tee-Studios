import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TshirtViewerMobile extends StatefulWidget {
  const TshirtViewerMobile({super.key});

  @override
  State<TshirtViewerMobile> createState() => _TshirtViewerMobileState();
}

class _TshirtViewerMobileState extends State<TshirtViewerMobile> {
  HttpServer? _server;
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startLocalServer();
  }

  Future<void> _startLocalServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(_handleHttpRequest);

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0E1015))
        ..loadRequest(
          Uri.parse('http://127.0.0.1:${_server!.port}/tshirt_customizer.html'),
        );

      if (mounted) {
        setState(() {
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleHttpRequest(HttpRequest request) async {
    try {
      String path = request.uri.path;
      if (path == '/' || path.isEmpty) {
        path = '/tshirt_customizer.html';
      }
      if (path.startsWith('/')) {
        path = path.substring(1);
      }

      String assetPath;
      ContentType contentType;

      if (path.endsWith('.html')) {
        assetPath = 'web/tshirt_customizer.html';
        contentType = ContentType.html;
      } else if (path.endsWith('.js')) {
        assetPath = 'web/$path';
        contentType = ContentType('application', 'javascript');
      } else if (path.endsWith('.glb')) {
        assetPath = 'assets/tshirt-mockup.glb';
        contentType = ContentType('model', 'gltf-binary');
      } else {
        assetPath = 'web/$path';
        contentType = ContentType.binary;
      }

      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List buffer = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.contentType = contentType;
      request.response.statusCode = HttpStatus.ok;
      request.response.add(buffer);
      await request.response.close();
    } catch (e) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('File not found: ${request.uri.path}');
      await request.response.close();
    }
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E1015),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6366F1)),
              SizedBox(height: 16),
              Text(
                'Starting 3D Mockup Studio...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E1015),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error starting 3D viewer: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E1015),
      body: SafeArea(
        child: WebViewWidget(controller: _controller!),
      ),
    );
  }
}

Widget buildTshirtViewerWidget() {
  return const TshirtViewerMobile();
}
