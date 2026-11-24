import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void downloadBytesAsPngWeb(Uint8List bytes, String fileName) {
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
}
