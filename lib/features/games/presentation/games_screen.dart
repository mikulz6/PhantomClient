import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/game_card.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 顶部导航栏 / 搜索栏
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background.withOpacity(0.9),
            elevation: 0,
            title: Row(
              children: [
                const Text(
                  "CloudGaming",
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 推荐 Banner (Carousel) - 可以在这里放 Steam 大图
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                // 模拟渐变背景图
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text("本周主推：黑神话·悟空", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // 分类标题 1：热销榜
          _buildSectionHeader("热销榜 · High Energy", Icons.local_fire_department, Colors.orange),

          // 游戏列表 - 双列
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7, // 竖版海报比例
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return GameCard(
                    title: "Cyberpunk 2077",
                    imageUrl: "https://placehold.co/300x400/png?text=Game+${index+1}", // 占位图
                    tags: const ["RPG", "开放世界", "光追"],
                  );
                },
                childCount: 4,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 分类标题 2：动作冒险
          _buildSectionHeader("动作 · Action", Icons.sports_esports, Colors.blue),

          // 游戏列表 - 这一组
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return GameCard(
                    title: "Elden Ring",
                    imageUrl: "https://placehold.co/300x400/1A1D24/FFFFFF/png?text=EldenRing",
                    tags: const ["魂类", "困难", "高分"],
                  );
                },
                childCount: 6,
              ),
            ),
          ),
          
          // 底部留白，防止被 BottomBar 遮挡
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
