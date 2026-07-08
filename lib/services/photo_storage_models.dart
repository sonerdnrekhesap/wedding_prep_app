enum ItemPhotoType {
  inspiration('inspiration'),
  product('product'),
  receipt('receipt');

  const ItemPhotoType(this.fileKey);

  final String fileKey;
}

class StoredPhotoPaths {
  const StoredPhotoPaths({
    required this.imagePath,
    required this.thumbPath,
  });

  final String imagePath;
  final String thumbPath;
}
