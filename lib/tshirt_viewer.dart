import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/tshirt_controller.dart';
import 'tshirt_viewer_2d.dart';
import 'tshirt_viewer_stub.dart'
    if (dart.library.js_interop) 'tshirt_viewer_web.dart'
    if (dart.library.io) 'tshirt_viewer_mobile.dart'
    as platform_impl;

class TshirtViewer extends StatelessWidget {
  const TshirtViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TshirtController.to;

    return Obx(() {
      if (controller.is2DView.value) {
        return TshirtViewer2D(key: key);
      }
      return platform_impl.buildTshirtViewerWidget(key: key);
    });
  }
}
