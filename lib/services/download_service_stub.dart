import 'dart:typed_data';

import 'download_service.dart';

DownloadService createDownloadService() => const _StubDownloadService();

class _StubDownloadService implements DownloadService {
  const _StubDownloadService();

  @override
  Future<bool> downloadPng(
    Uint8List bytes, {
    String fileName = 'tee-studios-mockup.png',
  }) async {
    return false;
  }
}
