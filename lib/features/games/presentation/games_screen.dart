import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/games_provider.dart';
import '../../domain/game_model.dart';
import 'widgets/game_card.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (games) {
          // 简单的本地过滤
          final topSellers = games.take(6).toList();
          final actionGames = games.where((g) => g.tags.contains("动作") || g.category == "FPS/TPS").take(4).toList();
          final rpgGames = games.where((g) => g.tags.contains("角色扮演") || g.category == "RPG").toList();

          return CustomScrollView(
            slivers: [
              // 顶部导航
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background.withOpacity(0.95),
                title: const Text(
                  "CloudGaming", 
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  const SizedBox(width: 8),
                ],
              ),

              // 1. Featured Hero (大推荐)
              if (games.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildFeaturedHero(context, games.first),
                ),

              // 2. 分类入口 (子页面入口)
              SliverToBoxAdapter(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryItem(context, "热门精选", Icons.local_fire_department, Colors.orange),
                      _buildCategoryItem(context, "RPG", Icons.explore, Colors.purple),
                      _buildCategoryItem(context, "FPS/TPS", Icons.gps_fixed, Colors.blue),
                      _buildCategoryItem(context, "竞速狂飙", Icons.speed, Colors.red),
                      _buildCategoryItem(context, "独立佳作", Icons.videogame_asset, Colors.green),
                    ],
                  ),
                ),
              ),

              // 3. 热销榜 (双列)
              _buildSectionHeader("热销榜 · Top Sellers"),
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
                      final game = topSellers[index];
                      return GestureDetector(
                        onTap: () => _navigateToDetail(context, game),
                        child: GameCard(
                          title: game.name,
                          imageUrl: game.posterImage,
                          tags: game.tags.take(2).toList(),
                        ),
                      );
                    },
                    childCount: topSellers.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // 4. 动作冒险 (横向大图，独占一行)
              _buildSectionHeader("动作冒险 · Action"),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = actionGames[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () => _navigateToDetail(context, game),
                        child: _buildWideGameCard(game),
                      ),
                    );
                  },
                  childCount: actionGames.length,
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, GameModel game) {
    // 使用 GoRouter 传递对象有点麻烦，通常传递 ID
    // 这里为了演示简单，直接 push
    context.push('/game/${game.id}', extra: game);
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Container(
              width: 4, height: 18, 
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedHero(BuildContext context, GameModel game) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, game),
      child: Container(
        height: 240,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: CachedNetworkImageProvider(game.headerImage),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text("本周主推", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                game.shortDescription,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildWideGameCard(GameModel game) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: CachedNetworkImage(imageUrl: game.headerImage, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(game.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: game.tags.take(2).map((t) => Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))).toList(),
                  ),
                  const Spacer(),
                  Text("极高画质 · 60 FPS", style: TextStyle(fontSize: 10, color: AppColors.success)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        context.push('/category/$title');
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
