import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ItemPhotoPreview extends StatelessWidget {
  const ItemPhotoPreview({
    super.key,
    required this.path,
    required this.icon,
    this.size = 72,
    this.onTap,
  });

  final String? path;
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPath = path != null && path!.isNotEmpty;
    final child = hasPath
        ? Image.network(
            path!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _Placeholder(icon: icon, size: size),
          )
        : _Placeholder(icon: icon, size: size);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: AppColors.creamDeep,
        child: InkWell(onTap: hasPath ? onTap : null, child: child),
      ),
    );
  }
}

class FullScreenPhotoPage extends StatelessWidget {
  const FullScreenPhotoPage({
    super.key,
    required this.title,
    required this.path,
  });

  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      body: Center(
        child: Image.network(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'Fotoğraf bulunamadı',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(icon, color: AppColors.rose),
    );
  }
}
