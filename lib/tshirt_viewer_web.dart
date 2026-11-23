import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;
import 'controllers/tshirt_controller.dart';

class TshirtViewerWeb extends StatefulWidget {
  const TshirtViewerWeb({super.key});

  @override
  State<TshirtViewerWeb> createState() => _TshirtViewerWebState();
}

class _TshirtViewerWebState extends State<TshirtViewerWeb> {
  static web.HTMLIFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _setupCommunication();
  }

  void _setupCommunication() {
    // Listen for messages from Three.js iframe
    web.window.addEventListener(
      'message',
      (web.MessageEvent event) {
        try {
          final rawData = event.data;
          if (rawData != null) {
            String? jsonStr;
            if (rawData.isA<JSString>()) {
              jsonStr = (rawData as JSString).toDart;
            }
            if (jsonStr != null) {
              final Map<String, dynamic> map = jsonDecode(jsonStr);
              if (Get.isRegistered<TshirtController>()) {
                TshirtController.to.handleMessageFrom3D(map);
              }
            }
          }
        } catch (_) {}
      }.toJS,
    );

    // Register callback on controller
    if (Get.isRegistered<TshirtController>()) {
      TshirtController.to.onSend3DCommand = _sendCommandTo3D;
    }
  }

  static void _sendCommandTo3D(Map<String, dynamic> command) {
    try {
      final jsonStr = jsonEncode(command);
      _iframe?.contentWindow?.postMessage(jsonStr.toJS, '*'.toJS);
    } catch (e) {
      debugPrint('Error sending command to 3D Web: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'iframe',
      onElementCreated: (Object element) {
        final iframe = element as web.HTMLIFrameElement
          ..src = 'tshirt_customizer.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen';
        _iframe = iframe;
      },
    );
  }
}

Widget buildTshirtViewerWidget({Key? key}) {
  return TshirtViewerWeb(key: key);
}
