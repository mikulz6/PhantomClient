import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/machine_card.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "选择配置",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "智能调度最佳节点 · 低延迟 · 高画质",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const MachineCard(
                    gpuModel: "RTX 4070 Super",
                    price: "3600",
                    availableCount: 12,
                    recommendText: "极致 4K 光追体验，3A 大作首选",
                    themeColor: Colors.purpleAccent,
                    badgeText: "ULTRA",
                  ),
                  const MachineCard(
                    gpuModel: "RTX 3070",
                    price: "2600",
                    availableCount: 45,
                    recommendText: "2K 高刷流畅，主流大作完美运行",
                    themeColor: AppColors.primary,
                    badgeText: "HOT",
                  ),
                  const MachineCard(
                    gpuModel: "RTX 2060",
                    price: "1600",
                    availableCount: 0, // 模拟无机器
                    recommendText: "1080P 性价比之选，网游神器",
                    themeColor: Colors.blueGrey,
                  ),
                ]),
              ),
            ),
            
             // 底部留白
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
