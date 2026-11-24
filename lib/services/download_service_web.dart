import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'download_service.dart';

DownloadService createDownloadService() => const WebDownloadService();

class WebDownloadService implements DownloadService {
  const WebDownloadService();

  @override
  Future<bool> downloadPng(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    try {
      final blob = web.Blob(
        <JSUint8Array>[bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/png'),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName.endsWith('.png') ? fileName : '$fileName.png';
      anchor.click();
      web.URL.revokeObjectURL(url);
      return true;
    } catch (_) {
      return false;
    }
  }
}
