import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/games_provider.dart';
import '../../domain/game_model.dart';
import '../widgets/game_card.dart';

class DesktopGamesScreen extends ConsumerWidget {
  const DesktopGamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: gamesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (games) {
          return CustomScrollView(
            slivers: [
              // 1. 顶部 Header & 刘海分类
              _buildDesktopHeader(context),

              // 2. 游戏网格
              SliverPadding(
                padding: const EdgeInsets.all(32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280, // 限制卡片最大宽度，实现响应式
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.7, // 保持竖版封面比例
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      return GestureDetector(
                        onTap: () => context.push('/games/game/${game.id}', extra: game),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GameCard(
                            title: game.name,
                            imageUrl: game.posterImage,
                            tags: game.tags.take(3).toList(),
                          ),
                        ),
                      );
                    },
                    childCount: games.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            const Text(
              "Library",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),
            
            // 刘海分类栏 (Category Bar)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildCategoryTab("全部", isActive: true),
                  _buildCategoryTab("动作"),
                  _buildCategoryTab("射击"),
                  _buildCategoryTab("角色扮演"),
                  _buildCategoryTab("策略"),
                  _buildCategoryTab("竞速"),
                  _buildCategoryTab("独立"),
                  _buildCategoryTab("体育"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, {bool isActive = false}) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
