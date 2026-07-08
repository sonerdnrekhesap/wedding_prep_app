import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const title = TextStyle(
    color: AppColors.ink,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: AppColors.ink,
    letterSpacing: 0,
  );

  static const muted = TextStyle(
    color: AppColors.muted,
    letterSpacing: 0,
  );
}
