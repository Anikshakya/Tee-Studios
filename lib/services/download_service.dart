import 'dart:typed_data';

import 'download_service_stub.dart'
    if (dart.library.io) 'download_service_io.dart'
    if (dart.library.js_interop) 'download_service_web.dart';

abstract interface class DownloadService {
  factory DownloadService() => createDownloadService();

  Future<bool> downloadPng(Uint8List bytes, {String fileName});
}
