import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'controllers/tshirt_controller.dart';

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
  bool _is3DReady = false;
  final List<Map<String, dynamic>> _pending3DCommands =
      <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _startLocalServer();
  }

  Future<void> _startLocalServer() async {
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server!.listen(_handleHttpRequest);

      // Build controller in two steps so the closure can reference _controller
      final wvc = WebViewController();
      wvc
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF0E1015))
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url) {
            // Once the page is fully loaded, force a resize so Three.js
            // matches the actual WebView dimensions (not window.innerWidth from iframe)
            Future.delayed(const Duration(milliseconds: 200), () {
              _runJavaScriptSafely(
                wvc,
                'if(typeof onWindowResize==="function") onWindowResize();',
              );
            });
            Future.delayed(const Duration(milliseconds: 600), () {
              _runJavaScriptSafely(
                wvc,
                'if(typeof onWindowResize==="function") onWindowResize();',
              );
            });
          },
        ))
        ..addJavaScriptChannel(
          'FlutterBridge',
          onMessageReceived: (JavaScriptMessage message) {
            try {
              final Map<String, dynamic> data = jsonDecode(message.message);
              if (Get.isRegistered<TshirtController>()) {
                final controller = TshirtController.to;
                if (data['type'] == 'READY') {
                  if (!mounted) return;
                  setState(() {
                    _is3DReady = true;
                  });
                  for (final command in List<Map<String, dynamic>>.from(
                    _pending3DCommands,
                  )) {
                    _sendCommandTo3D(wvc, command);
                  }
                  _pending3DCommands.clear();
                }
                controller.handleMessageFrom3D(data);
              }
            } catch (e) {
              debugPrint('FlutterBridge error: $e');
            }
          },
        )
        ..loadRequest(
          Uri.parse('http://127.0.0.1:${_server!.port}/tshirt_customizer.html'),
        );

      if (Get.isRegistered<TshirtController>()) {
        TshirtController.to.onSend3DCommand = (command) {
          if (_is3DReady) {
            _sendCommandTo3D(wvc, command);
          } else {
            _pending3DCommands
              ..removeWhere(
                (pending) => pending['type'] == command['type'],
              )
              ..add(command);
          }
        };
      }

      if (mounted) {
        setState(() {
          _controller = wvc;
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

  void _sendCommandTo3D(WebViewController webView, Map<String, dynamic> command) {
    final jsonStr = jsonEncode(command);
    _runJavaScriptSafely(
      webView,
      'if(typeof window.flutterBridgeReceive==="function") '
      'window.flutterBridgeReceive(${jsonEncode(jsonStr)});',
    );
  }

  Future<void> _runJavaScriptSafely(
    WebViewController webView,
    String source,
  ) async {
    try {
      await webView.runJavaScript(source);
    } on PlatformException catch (e) {
      if (!mounted) return;
      debugPrint('3D WebView JavaScript error: ${e.code}: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      debugPrint('3D WebView JavaScript error: $e');
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<TshirtController>() &&
        TshirtController.to.onSend3DCommand != null) {
      TshirtController.to.onSend3DCommand = null;
    }
    _pending3DCommands.clear();
    _server?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
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
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error starting 3D viewer: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    return WebViewWidget(
      controller: _controller!,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}

Widget buildTshirtViewerWidget({Key? key}) {
  return TshirtViewerMobile(key: key);
}
