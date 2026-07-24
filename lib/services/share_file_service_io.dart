import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFileService {
  const ShareFileService();

  Future<void> shareTextFile({
    required String fileName,
    required String content,
    required String subject,
    String mimeType = 'text/plain',
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    final bytes = <int>[0xEF, 0xBB, 0xBF, ...utf8.encode(content)];
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: subject,
    );
  }

  Future<void> shareBytesFile({
    required String fileName,
    required Uint8List bytes,
    required String subject,
    required String mimeType,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: subject,
    );
  }
}
