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
          final topSellers = games.take(10).toList(); // 假定前10是热销

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background.withOpacity(0.95),
                title: const Text("CloudGaming", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),

              // 1. 本周主推
              if (games.isNotEmpty)
                SliverToBoxAdapter(child: _buildFeaturedHero(context, games.first)),

              // 2. 玩法分类 (你的指定列表)
              _buildSectionHeader("玩法类型 · Genre"),
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildChip(context, "JRPG", Colors.pinkAccent),
                      _buildChip(context, "ARPG", Colors.orangeAccent),
                      _buildChip(context, "魂与类魂", Colors.redAccent),
                      _buildChip(context, "射击游戏", Colors.blueAccent),
                      _buildChip(context, "运动类游戏", Colors.greenAccent),
                      _buildChip(context, "独立佳作", Colors.purpleAccent),
                      _buildChip(context, "网游", Colors.cyanAccent),
                      _buildChip(context, "免费游戏", Colors.amberAccent),
                    ],
                  ),
                ),
              ),

              // 3. 厂商分类
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
                      _buildChip(context, "Valve", Colors.black45),
                      _buildChip(context, "万代", Colors.orangeAccent),
                    ],
                  ),
                ),
              ),

              // 4. 热销榜
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
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text(label),
        backgroundColor: color.withOpacity(0.2),
        side: BorderSide(color: color.withOpacity(0.5)),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
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
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(16),
          child: Text(game.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
