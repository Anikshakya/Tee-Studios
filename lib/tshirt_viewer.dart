import 'package:flutter/material.dart';
import 'tshirt_viewer_stub.dart'
    if (dart.library.js_interop) 'tshirt_viewer_web.dart' as platform_impl;

class TshirtViewer extends StatelessWidget {
  const TshirtViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return platform_impl.buildTshirtViewerWidget();
  }
}
