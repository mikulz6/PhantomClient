import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          final topSellers = games.take(10).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background.withOpacity(0.95),
                title: const Text("CloudGaming", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textPrimary)),
                actions: [
                  IconButton(icon: const Icon(Icons.search, color: AppColors.textPrimary), onPressed: () {}),
                ],
              ),

              if (games.isNotEmpty)
                SliverToBoxAdapter(child: _buildFeaturedHero(context, games.first)),

              _buildSectionHeader("热门品类 · Genre"),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // 颜色可以根据类型感觉来配
                      _buildChip(context, "开放世界", Colors.green),
                      _buildChip(context, "恐怖惊悚", Colors.grey),
                      _buildChip(context, "肉鸽莱克", Colors.deepPurple),
                      _buildChip(context, "双人合作", Colors.pinkAccent),
                      _buildChip(context, "射击游戏", Colors.blue),
                      _buildChip(context, "JRPG", Colors.indigo),
                      _buildChip(context, "赛博朋克", Colors.cyanAccent),
                      _buildChip(context, "策略模拟", Colors.brown),
                      _buildChip(context, "格斗竞技", Colors.redAccent),
                      _buildChip(context, "二次元", Colors.orangeAccent),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader("信仰厂牌 · Studio"),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildChip(context, "Rockstar", Colors.orange),
                      _buildChip(context, "CDPR", Colors.red),
                      _buildChip(context, "索尼", Colors.blue),
                      _buildChip(context, "任天堂", Colors.red),
                      _buildChip(context, "微软", Colors.green),
                      _buildChip(context, "米哈游", Colors.purpleAccent),
                      _buildChip(context, "EA", Colors.black),
                      _buildChip(context, "育碧", Colors.indigo),
                      _buildChip(context, "Larian", Colors.amber),
                      _buildChip(context, "Valve", Colors.black45),
                      _buildChip(context, "动视暴雪", Colors.blueGrey),
                      _buildChip(context, "卡普空", Colors.yellow[800]!),
                      _buildChip(context, "万代", Colors.orangeAccent),
                      _buildChip(context, "SE", Colors.grey),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader("热销推荐 · Top Sellers"),
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
                        onTap: () => context.push('/games/game/${game.id}', extra: game),
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  // ... _buildSectionHeader, _buildChip, _buildFeaturedHero 保持不变 ...
  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        labelStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        avatar: CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 6, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
        onPressed: () => context.push('/games/category/$label'),
      ),
    );
  }

  Widget _buildFeaturedHero(BuildContext context, GameModel game) {
    return GestureDetector(
      onTap: () => context.push('/games/game/${game.id}', extra: game),
      child: Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(image: CachedNetworkImageProvider(game.headerImage), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          child: Text(game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
