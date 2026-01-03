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
                backgroundColor: AppColors.background.withOpacity(0.95), // 浅色磨砂
                // 标题改为黑色
                title: const Text("CloudGaming", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.textPrimary)),
                actions: [
                  IconButton(icon: const Icon(Icons.search, color: AppColors.textPrimary), onPressed: () {}),
                ],
              ),

              if (games.isNotEmpty)
                SliverToBoxAdapter(child: _buildFeaturedHero(context, games.first)),

              _buildSectionHeader("玩法类型 · Genre"),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Chip 颜色调整，不要太浅看不清
                      _buildChip(context, "JRPG", Colors.pink),
                      _buildChip(context, "ARPG", Colors.orange),
                      _buildChip(context, "魂与类魂", Colors.red),
                      _buildChip(context, "射击游戏", Colors.blue),
                      _buildChip(context, "运动类游戏", Colors.green),
                      _buildChip(context, "独立佳作", Colors.purple),
                      _buildChip(context, "网游", Colors.cyan),
                      _buildChip(context, "免费游戏", Colors.amber),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader("知名厂商 · Studio"),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildChip(context, "索尼", Colors.blue),
                      _buildChip(context, "微软", Colors.green),
                      _buildChip(context, "SE", Colors.grey),
                      _buildChip(context, "Sega", Colors.blueGrey),
                      _buildChip(context, "卡普空", Colors.orange),
                      _buildChip(context, "科乐美", Colors.red),
                      _buildChip(context, "育碧", Colors.indigo),
                      _buildChip(context, "Valve", Colors.black),
                      _buildChip(context, "万代", Colors.orangeAccent),
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

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        // 确保标题是深色
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white, // 白底
        side: BorderSide(color: Colors.grey.withOpacity(0.2)), // 极淡边框
        // 阴影
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        labelStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold), // 黑字
        avatar: CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 6, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle))), // 带个小色点
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
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)), // 柔和阴影
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Hero 文字需要深色背景衬托，所以这里保留局部渐变黑，或者改为白色 Glass
            gradient: const LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          // 这里必须是白字，因为背景是图片
          child: Text(game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
