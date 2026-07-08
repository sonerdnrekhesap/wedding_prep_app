import 'package:image_picker/image_picker.dart';

import 'photo_storage_models.dart';

class PhotoStorageService {
  const PhotoStorageService();

  Future<StoredPhotoPaths> saveItemPhoto({
    required String itemId,
    required ItemPhotoType type,
    required XFile source,
  }) async {
    return StoredPhotoPaths(imagePath: source.path, thumbPath: source.path);
  }

  Future<void> deletePhotoPaths(Iterable<String?> paths) async {}

  Future<void> deleteItemPhotos(String itemId) async {}

  Future<void> deleteAllItemPhotos() async {}

  Future<bool> exists(String? path) async {
    return path != null && path.isNotEmpty;
  }
}
