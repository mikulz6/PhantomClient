import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/native_bridge.dart';
import '../domain/game_model.dart';
import 'widgets/fps_chart.dart';

class GameDetailScreen extends StatefulWidget {
  final GameModel game;
  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final List<Color> _neonColors = const [
    Color(0xFF00FFCC), 
    Color(0xFFFF66CC), 
    Color(0xFFCCFF00), 
    Color(0xFF00FFFF), 
    Color(0xFFFF9966), 
    Color(0xFFCC99FF), 
    Color(0xFF66FF99), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background, // 白底
            iconTheme: const IconThemeData(color: Colors.black), // 返回按钮黑色 (如果图是浅色) -> 这里比较棘手，通常用白色带阴影
            leading: Container(
               margin: const EdgeInsets.all(8),
               decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
               child: const BackButton(color: Colors.black),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.game.headerImage,
                fit: BoxFit.cover,
                // 不需要 darken 了，我们要清新的图
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.game.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.game.tags.map((tag) => _buildNeonTag(tag)).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("游戏简介", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(widget.game.shortDescription, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)), // 深灰简介
                  const SizedBox(height: 24),
                  const Text("云端性能预测", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  FpsChart(performance: widget.game.performance),
                  const SizedBox(height: 8),
                  // CPU 信息改为深灰小字
                  Text("RTX 2060/3070 搭载: ${widget.game.performance.cpu2060}", style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  Text("RTX 4070S 搭载: ${widget.game.performance.cpu4070s}", style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  
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

  Widget _buildNeonTag(String text) {
    final color = _neonColors[text.hashCode.abs() % _neonColors.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4), // 阴影改淡一点
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black, 
          fontSize: 12,
          fontWeight: FontWeight.w900, 
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white, // 纯白底
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))), // 极淡分割线
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save, size: 20),
                label: const Text("个人磁盘"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary, // 黑字
                  side: const BorderSide(color: Color(0xFFDDDDDD)), // 浅灰框
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _showLaunchDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // 官方蓝
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0, // PS App 风格通常是扁平的
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("选择启动方式", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
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
          color: const Color(0xFFF5F5F7), // 浅灰背景
          borderRadius: BorderRadius.circular(16),
          // 无边框，纯色块
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMachineSelection({required bool isSteam}) {
     // 耦合测试：调用 Native 启动串流
     // TODO: 在真实场景中，这里应该弹窗选择机器，然后传入选中的机器 IP
     const String demoHost = "192.168.1.2"; // 替换为你的 Sunshine 主机 IP
     const int demoAppId = 1; 

     NativeBridge.startGame(demoHost, demoAppId);

     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("正在调起 Moonlight 核心...")),
     );
  }
}
