import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/games_provider.dart';
import '../../domain/game_model.dart';

class CategoryScreen extends ConsumerWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesByCategoryProvider(categoryName));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (games) {
          if (games.isEmpty) return const Center(child: Text("暂无该分类游戏"));

          return CustomScrollView(
            slivers: [
              // 1. 缩影海报 Header (Collage)
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  background: Stack(
                    children: [
                      // 拼贴图背景：取前 4 个游戏的图拼在一起
                      _buildCollageBackground(games),
                      // 遮罩
                      Container(color: Colors.black.withOpacity(0.6)),
                    ],
                  ),
                ),
              ),

              // 2. 游戏列表
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 双列展示，效率更高
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      return _buildGameGridItem(context, game);
                    },
                    childCount: games.length,
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollageBackground(List<GameModel> games) {
    // 简单拼贴：取前4张图做 2x2 网格
    final displayGames = games.take(4).toList();
    if (displayGames.isEmpty) return const SizedBox();

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              if (displayGames.length > 0) Expanded(child: CachedNetworkImage(imageUrl: displayGames[0].headerImage, fit: BoxFit.cover)),
              if (displayGames.length > 1) Expanded(child: CachedNetworkImage(imageUrl: displayGames[1].headerImage, fit: BoxFit.cover)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              if (displayGames.length > 2) Expanded(child: CachedNetworkImage(imageUrl: displayGames[2].headerImage, fit: BoxFit.cover)),
              if (displayGames.length > 3) Expanded(child: CachedNetworkImage(imageUrl: displayGames[3].headerImage, fit: BoxFit.cover)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameGridItem(BuildContext context, GameModel game) {
    return GestureDetector(
      onTap: () => context.push('/games/game/${game.id}', extra: game),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: game.posterImage,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: AppColors.surfaceLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (game.tags.isNotEmpty)
                        Text(game.tags.first, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const Spacer(),
                      // 简单显示一个 3070 的 FPS 指示
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text("60+", style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
