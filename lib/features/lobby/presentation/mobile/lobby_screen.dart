import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../lobby/data/lobby_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  // 用于计时刷新的 Timer (辅助)
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    // 每秒刷新一次 UI 以更新计时器
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ref.read(lobbyProvider).currentSession != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyProvider);
    final session = lobbyState.currentSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // 如果有会话，显示控制台(子页2)；否则显示列表(子页1)
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: session != null 
            ? _buildActiveSessionView(session) 
            : _buildMachineListView(lobbyState),
        ),
      ),
    );
  }

  // --- 子页 1: 机器大厅 ---
  Widget _buildMachineListView(LobbyState state) {
    return CustomScrollView(
      key: const ValueKey('list'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "选择您的配置",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "高性能云端显卡 · 即刻交付",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // 机器列表
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // 最后一个作为"敬请期待"
                if (index == state.machines.length) {
                  return _buildComingSoonCard();
                }
                final machine = state.machines[index];
                final occupied = state.occupiedCounts[machine.id] ?? 0;
                final remaining = machine.totalCount - occupied;
                
                return _buildMachineCard(machine, remaining);
              },
              childCount: state.machines.length + 1, // +1 for Coming Soon
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMachineCard(MachineModel machine, int remaining) {
    final bool isAvailable = remaining > 0;

    return GestureDetector(
      onTap: isAvailable ? () => _handleRent(machine) : null,
      child: Container(
        height: 180, // 一人一行，高度给足
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // 裁切圆角
        child: Stack(
          children: [
            // 1. 背景图 (显卡特写)
            Positioned(
              right: -50, // 往右移一点，露出主体
              top: 0,
              bottom: 0,
              width: 300,
              child: CachedNetworkImage(
                imageUrl: machine.imageUrl,
                fit: BoxFit.contain,
                color: !isAvailable ? Colors.grey : null, // 没货变灰
                colorBlendMode: !isAvailable ? BlendMode.saturation : null,
              ),
            ),
            
            // 2. 渐变遮罩 (保证左侧文字清晰)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // 3. 内容信息
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black, // 永远黑色，最清晰
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      machine.desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 价格
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${machine.price}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const Text(
                        " 金币/时",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. 右下角状态 (剩余数量)
            Positioned(
              bottom: 16,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.black.withOpacity(0.8) : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable ? "剩余 ${machine.id.toUpperCase()}: $remaining" : "暂无库存",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "更多机型拓展中 · 敬请期待",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _handleRent(MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认上机"),
        content: Text("将分配 ${machine.name} 实例。\n单价: ${machine.price} 金币/时。"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // 触发状态改变 -> 自动跳转到控制台页
              ref.read(lobbyProvider.notifier).startSession(machine.id);
            },
            child: const Text("立即开机"),
          ),
        ],
      ),
    );
  }

  // --- 子页 2: 控制台 (游戏中) ---
  Widget _buildActiveSessionView(GamingSession session) {
    final duration = session.duration;
    final String timeStr = "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    
    // 计算消耗 (简单的每分钟扣除逻辑用于演示)
    // 假设价格是每小时，每分钟 = price / 60
    final int cost = ((duration.inMinutes + 1) * (ref.read(lobbyProvider).machines.firstWhere((m) => m.id == session.machineId).price / 60)).toInt();

    return Center(
      key: const ValueKey('session'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 脉冲动画图标
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_done, size: 80, color: AppColors.success),
            ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1.seconds).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1,1)),
            
            const SizedBox(height: 32),
            
            const Text("正在运行", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              session.machineName,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
              child: Text("ID: ${session.machineNo}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 48),

            // 计时器
            const Text("已上机时长", style: TextStyle(color: Colors.grey)),
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()], // 等宽数字
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            Text("当前消费预估: $cost 金币", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),

            const Spacer(),

            // 下机按钮
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => _handleStopSession(cost),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.power_settings_new),
                label: const Text("下机结算", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // 仅隐藏控制台，回到大厅查看其他信息（如果你允许的话）
                // 但通常下机前不应该离开这个页面，这里可以放一个“进入桌面”的按钮
              }, 
              child: const Text("返回桌面继续游戏", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStopSession(int finalCost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认下机？"),
        content: Text("本次使用共消耗 $finalCost 金币。\n确定要结束当前的云电脑会话吗？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("继续游戏")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context); // 关弹窗
              ref.read(lobbyProvider.notifier).endSession(); // 结束会话 -> 自动切回列表页
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("会话结束，扣除 $finalCost 金币")));
            },
            child: const Text("确认下机"),
          ),
        ],
      ),
    );
  }
}
