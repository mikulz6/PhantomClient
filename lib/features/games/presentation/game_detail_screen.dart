import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/game_model.dart';
import 'widgets/fps_chart.dart';

class GameDetailScreen extends StatefulWidget {
  final GameModel game;
  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.game.headerImage,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.game.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // 彩色实心小方框标签
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.game.tags.map((tag) => _buildColoredTag(tag)).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text("游戏简介", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.game.shortDescription, style: const TextStyle(color: Colors.white70, height: 1.5)),
                  const SizedBox(height: 24),
                  const Text("云端性能预测", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FpsChart(performance: widget.game.performance),
                  const SizedBox(height: 8),
                  Text("RTX 2060/3070 搭载: ${widget.game.performance.cpu2060}", style: const TextStyle(fontSize: 12, color: Colors.white38)),
                  Text("RTX 4070S 搭载: ${widget.game.performance.cpu4070s}", style: const TextStyle(fontSize: 12, color: Colors.white38)),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildColoredTag(String text) {
    // 生成高饱和度的实心颜色
    final color = Colors.primaries[text.hashCode % Colors.primaries.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 紧凑
      decoration: BoxDecoration(
        color: color, // 实心背景
        borderRadius: BorderRadius.circular(4), // 小圆角方框
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white, // 白色文字
          fontSize: 12,
          fontWeight: FontWeight.bold, // 粗体
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: SafeArea(
        child: Row(
          children: [
            // 左边：个人磁盘
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("打开个人云磁盘...")));
                },
                icon: const Icon(Icons.save, size: 20),
                label: const Text("个人磁盘"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 右边：启动游戏
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _showLaunchDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
                child: const Text("启动游戏", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLaunchDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("选择启动方式", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildLaunchOption(
                icon: Icons.cloud_download,
                title: "启动社区资源 (推荐)",
                subtitle: "直接进入游戏 · 扣除金币",
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _showMachineSelection(isSteam: false);
                },
              ),
              const SizedBox(height: 16),
              _buildLaunchOption(
                icon: Icons.account_circle,
                title: "使用 Steam 账号登录",
                subtitle: "进入桌面 · 需自行登录 Steam",
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _showMachineSelection(isSteam: true);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLaunchOption({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showMachineSelection({required bool isSteam}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("正在为您分配云机 (模式: ${isSteam ? 'Steam桌面' : '社区资源'})..."),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
