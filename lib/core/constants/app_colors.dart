import 'package:flutter/material.dart';

class AppColors {
  // 背景色 - 改为 PS App / Apple 风格的浅色
  static const Color background = Color(0xFFF5F5F7); // 浅灰背景，用于衬托白色卡片
  static const Color surface = Color(0xFFFFFFFF);    // 纯白卡片
  static const Color surfaceLight = Color(0xFFFFFFFF); // 在浅色模式下，surfaceLight 通常也是白色或极浅灰

  // 强调色 - PlayStation Blue，在白色背景上更鲜艳
  static const Color primary = Color(0xFF0070D1); // PS 官方蓝
  static const Color accent = Color(0xFF00439C);

  // 功能色
  static const Color success = Color(0xFF34C759); 
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // 文字颜色
  static const Color textPrimary = Color(0xFF000000); // 纯黑
  static const Color textSecondary = Color(0xFF6E6E73); // 深灰
  static const Color textTertiary = Color(0xFF86868B);
  
  // 玻璃磨砂效果的基础色 (浅色模式)
  static const Color glassBorder = Color(0x33000000); // 淡淡的黑线
  static const Color glassBackground = Color(0xB3FFFFFF); // 半透明白
}
