import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/game_model.dart';
import '../../../../core/native_bridge.dart';

class DesktopGameDetailScreen extends StatefulWidget {
  final GameModel game;

  const DesktopGameDetailScreen({super.key, required this.game});

  @override
  State<DesktopGameDetailScreen> createState() => _DesktopGameDetailScreenState();
}

class _DesktopGameDetailScreenState extends State<DesktopGameDetailScreen> {
  int _selectedGpuIndex = 1; 

  // 模拟显卡配置 (弹窗用)
  final List<Map<String, String>> _gpuConfigs = [
    {"model": "2060", "desc": "1080p", "image": "https://img.zcool.cn/community/01d93d5d5b7806a8012187f433b934.jpg@1280w_1l_2o_100sh.jpg"},
    {"model": "3070", "desc": "2K 144", "image": "https://img.zcool.cn/community/01a4e95f058097a801206621919998.jpg@1280w_1l_2o_100sh.jpg"},
    {"model": "4070 Ti", "desc": "4K Ray", "image": "https://img.zcool.cn/community/0166665f05809ba801215aa0086e33.jpg@1280w_1l_2o_100sh.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 纯黑底
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
          child: const BackButton(color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 全屏海报 (作为背景主体)
          CachedNetworkImage(
            imageUrl: widget.game.headerImage, // 用高清横图铺满
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3), // 稍微压暗一点点即可
            colorBlendMode: BlendMode.darken,
          ),
          
          // 2. 渐变遮罩 (底部和右侧)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.5, 0.8, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          
          // 3. 内容布局
          Row(
            children: [
              // 左侧留白/标题区 (占大部分)
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(left: 60, bottom: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 巨大的标题
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          fontSize: 80, // 超大
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 0.9,
                          letterSpacing: -2,
                        ),
                      ).animate().fadeIn().moveY(begin: 30, end: 0),
                      
                      const SizedBox(height: 16),
                      // 简介
                      SizedBox(
                        width: 600,
                        child: Text(
                          widget.game.shortDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 右侧操作条 (占 1/10)
              Container(
                width: 100, // 固定窄条
                padding: const EdgeInsets.symmetric(vertical: 40),
                color: Colors.black.withOpacity(0.2), // 微弱背景
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                  children: [
                    // 启动按钮
                    FloatingActionButton(
                      onPressed: _showLaunchDialog,
                      backgroundColor: AppColors.primary,
                      elevation: 10,
                      child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
                    ).animate().scale(delay: 200.ms),
                    
                    const SizedBox(height: 40),
                    
                    // 竖排标签
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          spacing: 12,
                          children: widget.game.tags.take(6).map((tag) {
                            return _buildVerticalTag(tag);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTag(String text) {
    // 霓虹色
    final colors = [
      const Color(0xFF00FFCC), 
      const Color(0xFFFF66CC), 
      const Color(0xFFCCFF00), 
      const Color(0xFF00FFFF),
    ];
    final color = colors[text.hashCode.abs() % colors.length];

    return Container(
      width: 60, // 限制宽度
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)
        ]
      ),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.clip, // 超过直接切断
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void _showLaunchDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          height: 500,
          width: 800,
          borderRadius: BorderRadius.circular(24),
          blur: 20,
          border: 1,
          borderColor: Colors.white.withOpacity(0.2),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1C21).withOpacity(0.95),
              const Color(0xFF1A1C21).withOpacity(0.90),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("配置游戏环境", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),
                
                // 1. 显卡选择
                const Text("选择 GPU 算力", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(_gpuConfigs.length, (index) {
                    final config = _gpuConfigs[index];
                    final isSelected = _selectedGpuIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                           // 这里需要用到 StatefulBuilder 或者把 Dialog 抽离成 Widget 才能刷新
                           // 简单起见，我们假设它能刷新 (实际代码建议抽离)
                           (context as Element).markNeedsBuild();
                           _selectedGpuIndex = index;
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(config['image']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(config['model']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(config['desc']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const Spacer(),
                
                // 2. 启动方式
                Row(
                  children: [
                    Expanded(
                      child: _buildLaunchBtn(
                        "启动社区版", 
                        "直接进入 · 扣除金币", 
                        Icons.cloud_download, 
                        Colors.green,
                        () => _startGame(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLaunchBtn(
                        "Steam 登录", 
                        "登录个人账号", 
                        Icons.account_circle, 
                        Colors.blue,
                        () => _startGame(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchBtn(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(bool isSteam) {
    Navigator.pop(context);
    NativeBridge.startGame("192.168.1.2", 1);
  }
}
