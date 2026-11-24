import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/download_service.dart';

Future<void> showExportPreviewDialog({
  required BuildContext context,
  required Uint8List bytes,
  required String title,
}) {
  final downloadService = const DownloadService();

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF14171F),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                maxHeight: 600,
              ),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
                if (kIsWeb)
                  FilledButton.icon(
                    onPressed: () => downloadService.downloadPng(bytes),
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  )
                else if (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.android)
                  FilledButton.icon(
                    onPressed: () => downloadService.sharePng(bytes),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: () => downloadService.savePngToDevice(bytes),
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save to Local'),
                  ),
                  FilledButton.icon(
                    onPressed: () => downloadService.sharePng(bytes),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
