import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final String name;
  final String dataUrl;

  const PickedImage({
    required this.name,
    required this.dataUrl,
  });
}

class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<Uint8List?> capturePng(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 2,
  }) async {
    try {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      if (byteData == null) return null;
      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } catch (error, stackTrace) {
      debugPrint('Error exporting PNG: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<PickedImage?> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 95,
      );
      if (file == null) return null;

      final bytes = await file.readAsBytes();
      final mimeType = file.mimeType ?? _mimeTypeFromName(file.name);
      return PickedImage(
        name: file.name,
        dataUrl: 'data:$mimeType;base64,${base64Encode(bytes)}',
      );
    } catch (error, stackTrace) {
      debugPrint('Error picking image: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Uint8List? dataUrlBytes(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return null;
    final separator = dataUrl.indexOf(',');
    if (separator < 0) return null;

    final metadata = dataUrl.substring(5, separator);
    final payload = dataUrl.substring(separator + 1);
    try {
      return metadata.contains(';base64')
          ? base64Decode(payload)
          : Uint8List.fromList(utf8.encode(Uri.decodeComponent(payload)));
    } catch (_) {
      return null;
    }
  }

  String _mimeTypeFromName(String name) {
    final extension = name.toLowerCase().split('.').last;
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'svg' => 'image/svg+xml',
      _ => 'image/png',
    };
  }
}
