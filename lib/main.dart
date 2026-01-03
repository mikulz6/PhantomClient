import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: CloudGamingApp()));
}

class CloudGamingApp extends StatelessWidget {
  const CloudGamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cloud Gaming',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // 强制深色主题
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
