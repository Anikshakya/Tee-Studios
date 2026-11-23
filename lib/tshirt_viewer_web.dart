import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class TshirtViewerWeb extends StatefulWidget {
  const TshirtViewerWeb({super.key});

  @override
  State<TshirtViewerWeb> createState() => _TshirtViewerWebState();
}

class _TshirtViewerWebState extends State<TshirtViewerWeb> {
  static bool _registered = false;
  static const String viewType = 'tshirt-3d-viewer-iframe';

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = web.HTMLIFrameElement()
            ..src = 'tshirt_customizer.html'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'fullscreen';
          return iframe;
        },
      );
      _registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: viewType);
  }
}

Widget buildTshirtViewerWidget() {
  return const TshirtViewerWeb();
}
