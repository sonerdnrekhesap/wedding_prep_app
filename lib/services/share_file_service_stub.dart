import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

class ShareFileService {
  const ShareFileService();

  Future<void> shareTextFile({
    required String fileName,
    required String content,
    required String subject,
    String mimeType = 'text/plain',
  }) async {
    await Share.share(content, subject: subject);
  }

  Future<void> shareBytesFile({
    required String fileName,
    required Uint8List bytes,
    required String subject,
    required String mimeType,
  }) async {
    await Share.share(
      '$fileName hazir. Bu platformda dosya paylasimi yerine metin paylasimi kullaniliyor.',
      subject: subject,
    );
  }
}
