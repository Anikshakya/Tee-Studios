import 'dart:io';
import 'dart:typed_data';

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
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = Directory('${Directory.current.path}/Documents');
      } else {
        directory = Directory.current;
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final safeName = fileName.endsWith('.png') ? fileName : '$fileName.png';
      await File('${directory.path}/$safeName').writeAsBytes(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }
}
