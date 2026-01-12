import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class DesktopProfileScreen extends StatelessWidget {
  const DesktopProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Center",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧：个人概览 (占 1/3)
                  Expanded(
                    flex: 4,
                    child: _buildLeftPanel(),
                  ),
                  
                  const SizedBox(width: 40),
                  
                  // 右侧：功能矩阵 (占 2/3)
                  Expanded(
                    flex: 8,
                    child: _buildRightPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2025),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.surfaceLight,
              child: Icon(Icons.person, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Guest User",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("UID: 88888888", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          
          const SizedBox(height: 48),
          
          // 资产展示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D7AF0), Color(0xFF2A52BE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text("当前余额 (金币)", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                const Text(
                  "12,500",
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: "monospace"),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("立即充值", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          const Text("Phantom Client v1.0.0", style: TextStyle(color: Colors.white30, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        
        // 功能网格
        Expanded(
          child: GridView.count(
            crossAxisCount: 3, // 一行三个卡片
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 1.5,
            children: [
              _buildFeatureCard("每日签到", "今日未签", Icons.calendar_today, Colors.orange),
              _buildFeatureCard("我的任务", "3 个待领取", Icons.task_alt, Colors.green),
              _buildFeatureCard("游戏存档", "云端同步中", Icons.cloud_upload, Colors.blue),
              _buildFeatureCard("显示设置", "4K / HDR", Icons.monitor, Colors.purple),
              _buildFeatureCard("手柄映射", "Xbox Layout", Icons.gamepad, Colors.red),
              _buildFeatureCard("账号管理", "绑定 Steam", Icons.link, Colors.teal),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E2025),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
