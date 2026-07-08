import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(18);
  static const pill = Radius.circular(999);

  static const card = BorderRadius.all(lg);
  static const field = BorderRadius.all(md);
}
