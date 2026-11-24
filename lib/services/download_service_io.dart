import 'dart:io';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

import 'download_service.dart';

DownloadService createDownloadService() => const IoDownloadService();

class IoDownloadService implements DownloadService {
  const IoDownloadService();

  @override
  Future<bool> downloadPng(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    try {
      final safeName = fileName.endsWith('.png') ? fileName : '$fileName.png';
      final tempDir = await Directory.systemTemp.createTemp('tee-studios');
      final file = await File('${tempDir.path}/$safeName').writeAsBytes(bytes);
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'Tee Studios mockup',
        ),
      );
      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;
    } catch (_) {
      return false;
    }
  }
}
