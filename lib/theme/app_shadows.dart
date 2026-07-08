import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const soft = [
    BoxShadow(
      color: Color(0x1F8E5564),
      blurRadius: 22,
      offset: Offset(0, 10),
    ),
  ];

  static const premium = [
    BoxShadow(
      color: Color(0x29A97921),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}
