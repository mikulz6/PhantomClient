import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    
    // 文本样式
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      bodyLarge: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
    ),

    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent, 
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // 卡片主题
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0, // PS 风格通常是平的或者极浅投影
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),

    // AppBar 主题
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary, // 图标和标题变黑
      elevation: 0,
    ),

    useMaterial3: true,
  );
}
