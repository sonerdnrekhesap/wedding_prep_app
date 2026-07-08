import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'photo_storage_models.dart';

class PhotoStorageService {
  const PhotoStorageService();

  Future<StoredPhotoPaths> saveItemPhoto({
    required String itemId,
    required ItemPhotoType type,
    required XFile source,
  }) async {
    final directory = await _itemsDirectory();
    final imagePath = '${directory.path}/${itemId}_${type.fileKey}.jpg';
    final thumbPath = '${directory.path}/${itemId}_${type.fileKey}_thumb.jpg';

    await source.saveTo(imagePath);

    // image_picker already receives a compressed image through imageQuality.
    // Keep the thumb path separate now so real thumbnail generation can drop in later.
    await File(imagePath).copy(thumbPath);

    return StoredPhotoPaths(imagePath: imagePath, thumbPath: thumbPath);
  }

  Future<void> deletePhotoPaths(Iterable<String?> paths) async {
    for (final path in paths.whereType<String>()) {
      if (path.isEmpty) continue;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> deleteItemPhotos(String itemId) async {
    final directory = await _itemsDirectory();
    if (!await directory.exists()) return;

    final files = directory.list();
    await for (final entity in files) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (name.startsWith('${itemId}_')) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> deleteAllItemPhotos() async {
    final directory = await _itemsDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<bool> exists(String? path) async {
    if (path == null || path.isEmpty) return false;
    return File(path).exists();
  }

  Future<Directory> _itemsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/wedding_prep_images/items');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
