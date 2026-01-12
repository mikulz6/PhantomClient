import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'desktop_main_scaffold.dart';

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 判断屏幕宽度
    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果宽度大于 800，视为桌面端/平板宽屏
        if (constraints.maxWidth > 800) {
          return DesktopMainScaffold(navigationShell: widget.navigationShell);
        }
        
        // 否则返回移动端布局
        return Scaffold(
          extendBody: true, 
          body: widget.navigationShell,
          bottomNavigationBar: _buildGlassBottomBar(),
        );
      },
    );
  }

  Widget _buildGlassBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            // 使用定义的 glassBackground (半透明白)
            color: AppColors.glassBackground,
            border: const Border(
              top: BorderSide(color: AppColors.glassBorder, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: (index) {
              widget.navigationShell.goBranch(
                index,
                initialLocation: index == widget.navigationShell.currentIndex,
              );
            },
            backgroundColor: Colors.transparent,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            // 确保图标颜色正确
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.gamepad_outlined),
                activeIcon: Icon(Icons.gamepad),
                label: '游戏',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dns_outlined), 
                activeIcon: Icon(Icons.dns),
                label: '大厅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
