import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class DesktopMainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DesktopMainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 左侧侧边栏
          _buildSideBar(context),
          
          // 右侧内容区
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar(BuildContext context) {
    return Container(
      width: 250, // 固定宽度侧边栏
      color: const Color(0xFF1A1C21), // 比背景稍亮一点的深色
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo / App Name
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.cloud_circle_rounded, color: AppColors.primary, size: 32),
                SizedBox(width: 12),
                Text(
                  "PHANTOM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 60),

          // Navigation Items
          _buildNavItem(context, 0, Icons.grid_view_rounded, "游戏库"),
          const SizedBox(height: 8),
          _buildNavItem(context, 1, Icons.dns_rounded, "服务器大厅"),
          const SizedBox(height: 8),
          _buildNavItem(context, 2, Icons.person_rounded, "个人中心"),
          
          const Spacer(),
          
          // Bottom Actions (Settings, etc)
          _buildNavItem(context, -1, Icons.settings_rounded, "设置", onTap: () {
            // TODO: Open Settings
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, {VoidCallback? onTap}) {
    final isSelected = index == navigationShell.currentIndex;
    final color = isSelected ? AppColors.primary : Colors.grey;
    final bgColor = isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => _onTap(context, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
