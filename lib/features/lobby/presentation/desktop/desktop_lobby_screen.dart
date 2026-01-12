import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../data/lobby_provider.dart';

class DesktopLobbyScreen extends ConsumerStatefulWidget {
  const DesktopLobbyScreen({super.key});

  @override
  ConsumerState<DesktopLobbyScreen> createState() => _DesktopLobbyScreenState();
}

class _DesktopLobbyScreenState extends ConsumerState<DesktopLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyProvider);
    final session = lobbyState.currentSession;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 标题区
            Row(
              children: [
                const Text(
                  "Server Lobby",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        "${lobbyState.machines.length} Nodes Online",
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // 2. 如果有会话，显示顶部状态条 (不全屏覆盖，方便多任务)
            if (session != null) 
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildActiveSessionBar(session),
              ),

            // 3. 机器网格
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400, // 卡片比较宽
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.6, // 宽卡片比例
                ),
                itemCount: lobbyState.machines.length + 1, // +1 for Coming Soon
                itemBuilder: (context, index) {
                   if (index == lobbyState.machines.length) {
                     return _buildComingSoonCard();
                   }
                   final machine = lobbyState.machines[index];
                   final occupied = lobbyState.occupiedCounts[machine.id] ?? 0;
                   final remaining = machine.totalCount - occupied;
                   return _buildDesktopMachineCard(machine, remaining);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopMachineCard(MachineModel machine, int remaining) {
    final bool isAvailable = remaining > 0;

    return GestureDetector(
      onTap: isAvailable ? () => _handleRent(machine) : null,
      child: MouseRegion(
        cursor: isAvailable ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1E2025), // 深灰底色
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // 1. 背景图 (显卡特写，稍微放大一点充满)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: machine.imageUrl,
                  fit: BoxFit.cover,
                  color: !isAvailable ? Colors.grey : Colors.black.withOpacity(0.6), // 压暗背景
                  colorBlendMode: !isAvailable ? BlendMode.saturation : BlendMode.darken,
                ),
              ),
              
              // 2. 内容信息
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Name & Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                machine.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  machine.desc,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                             Text(
                               "${machine.price}",
                               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                             ),
                             const Text(
                               "金币/时",
                               style: TextStyle(fontSize: 10, color: Colors.white70),
                             ),
                           ],
                         ),
                      ],
                    ),

                    // Bottom: Status & Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status
                        Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
                              color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAvailable ? "库存充足 ($remaining)" : "暂时缺货",
                              style: TextStyle(
                                color: isAvailable ? Colors.greenAccent : Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        // Action Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.white : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: isAvailable ? Colors.black : Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: Colors.white.withOpacity(0.3), size: 40),
          const SizedBox(height: 16),
          Text(
            "更多机型部署中",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionBar(GamingSession session) {
    final duration = session.duration;
    final String timeStr = "${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E2025), Color(0xFF15171B)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
        boxShadow: [
           BoxShadow(color: AppColors.success.withOpacity(0.1), blurRadius: 10),
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(Icons.cloud_done, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.machineName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("ID: ${session.machineNo}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: "monospace")),
              const Text("正在计费", style: TextStyle(color: AppColors.success, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 24),
          OutlinedButton(
            onPressed: () => _handleStopSession(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text("下机"),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {}, // 返回桌面
            child: const Text("进入桌面"),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  void _handleRent(MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252830),
        title: const Text("确认租用配置", style: TextStyle(color: Colors.white)),
        content: Text("即将在云端分配 ${machine.name} 实例。\n单价: ${machine.price} 金币/时。", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消")),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(lobbyProvider.notifier).startSession(machine.id);
            },
            child: const Text("立即开机"),
          ),
        ],
      ),
    );
  }

  void _handleStopSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252830),
        title: const Text("确认下机？", style: TextStyle(color: Colors.white)),
        content: const Text("确定要结束当前的云电脑会话并结算费用吗？", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("继续使用")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              ref.read(lobbyProvider.notifier).endSession();
            },
            child: const Text("确认下机"),
          ),
        ],
      ),
    );
  }
}
