import 'package:flutter/material.dart';

Widget buildTshirtViewerWidget({Key? key}) {
  return Center(
    key: key,
    child: const Text(
      '3D T-Shirt Mockup Studio is optimized for Flutter Web.\nPlease run with: flutter run -d chrome',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70, fontSize: 16),
    ),
  );
}
