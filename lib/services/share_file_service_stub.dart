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
}
