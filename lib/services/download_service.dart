import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'download_service_web.dart'
    if (dart.library.io) 'download_service_io.dart';

class DownloadService {
  const DownloadService();

  Future<bool> downloadPng(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    if (!kIsWeb) {
      return false;
    }

    try {
      downloadBytesAsPngWeb(bytes, fileName);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sharePng(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    if (kIsWeb) {
      return downloadPng(bytes, fileName: fileName);
    }

    try {
      final safeName = fileName.endsWith('.png') ? fileName : '$fileName.png';
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'image/png',
              name: safeName,
            ),
          ],
          text: 'Tee Studios mockup',
        ),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (_) {
      return false;
    }
  }

  Future<bool> savePngToDevice(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    if (kIsWeb) {
      return downloadPng(bytes, fileName: fileName);
    }

    try {
      final safeName = fileName.endsWith('.png') ? fileName : '$fileName.png';
      await Gal.putImageBytes(bytes, name: safeName);
      return true;
    } catch (_) {
      return false;
    }
  }
}
