import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// 机器型号定义
class MachineModel {
  final String id;
  final String name; // 如 "RTX 4070 Super"
  final String imageUrl; // 显卡美图
  final int totalCount;
  final int price; // 金币/小时
  final String desc; // 一句话描述

  MachineModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.totalCount,
    required this.price,
    required this.desc,
  });
}

// 当前会话状态
class GamingSession {
  final String machineId;
  final String machineName;
  final DateTime startTime;
  final String machineNo; // 分配的机器编号，如 "A-012"

  GamingSession({
    required this.machineId,
    required this.machineName,
    required this.startTime,
    required this.machineNo,
  });

  Duration get duration => DateTime.now().difference(startTime);
}

// 状态管理
class LobbyState {
  final List<MachineModel> machines;
  final Map<String, int> occupiedCounts; // 已占用数量
  final GamingSession? currentSession; // 当前是否在游戏中

  LobbyState({
    required this.machines,
    required this.occupiedCounts,
    this.currentSession,
  });

  LobbyState copyWith({
    List<MachineModel>? machines,
    Map<String, int>? occupiedCounts,
    GamingSession? currentSession,
    bool clearSession = false,
  }) {
    return LobbyState(
      machines: machines ?? this.machines,
      occupiedCounts: occupiedCounts ?? this.occupiedCounts,
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
    );
  }
}

// Notifier
class LobbyNotifier extends StateNotifier<LobbyState> {
  Timer? _timer;

  LobbyNotifier() : super(LobbyState(
    machines: [
      MachineModel(
        id: "4070s",
        name: "RTX 4070 Super",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/49d3e8c0-5403-4d43-9899-7333333f2022/w800", // ROG Strix
        totalCount: 50,
        price: 3600,
        desc: "极致光追 · 4K 144Hz",
      ),
      MachineModel(
        id: "3070",
        name: "RTX 3070",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/5b94f061-f308-4d50-934c-6f81878d2126/w800", // White Edition
        totalCount: 120,
        price: 2600,
        desc: "高刷利器 · 2K 165Hz",
      ),
      MachineModel(
        id: "2060",
        name: "RTX 2060",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/97a54133-722a-4357-9943-28f000300957/w800",
        totalCount: 200,
        price: 1600,
        desc: "性价比首选 · 1080P",
      ),
    ],
    occupiedCounts: {
      "4070s": 32,
      "3070": 85,
      "2060": 190, // 仅剩10台
    },
  ));

  void startSession(String machineId) {
    final machine = state.machines.firstWhere((m) => m.id == machineId);
    
    // 增加占用
    final newOccupied = Map<String, int>.from(state.occupiedCounts);
    newOccupied[machineId] = (newOccupied[machineId] ?? 0) + 1;

    // 创建会话
    final session = GamingSession(
      machineId: machineId,
      machineName: machine.name,
      startTime: DateTime.now(),
      machineNo: "${machineId.toUpperCase()}-${DateTime.now().millisecond}",
    );

    state = state.copyWith(occupiedCounts: newOccupied, currentSession: session);
    
    // 启动计时器刷新 UI (每秒)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // 触发 UI 重绘以显示时间变化
      state = state; 
    });
  }

  void endSession() {
    if (state.currentSession == null) return;
    
    final machineId = state.currentSession!.machineId;
    
    // 减少占用
    final newOccupied = Map<String, int>.from(state.occupiedCounts);
    if (newOccupied[machineId] != null && newOccupied[machineId]! > 0) {
      newOccupied[machineId] = newOccupied[machineId]! - 1;
    }

    _timer?.cancel();
    state = state.copyWith(occupiedCounts: newOccupied, clearSession: true);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyState>((ref) {
  return LobbyNotifier();
});
