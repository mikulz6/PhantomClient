import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';

// 机器型号定义
class MachineModel {
  final String id;
  final String name; // 如 "RTX 4070 Super"
  final String imageUrl; // 显卡美图
  final int totalCount;
  final int price; // 金币/小时
  final String desc; // 一句话描述
  final String region; // 区域：华北-北京、华东-上海
  final int ping; // 延迟 ms

  MachineModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.totalCount,
    required this.price,
    required this.desc,
    required this.region,
    required this.ping,
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
  final String selectedRegion; // 筛选状态

  LobbyState({
    required this.machines,
    required this.occupiedCounts,
    this.currentSession,
    this.selectedRegion = "全部",
  });

  LobbyState copyWith({
    List<MachineModel>? machines,
    Map<String, int>? occupiedCounts,
    GamingSession? currentSession,
    String? selectedRegion,
    bool clearSession = false,
  }) {
    return LobbyState(
      machines: machines ?? this.machines,
      occupiedCounts: occupiedCounts ?? this.occupiedCounts,
      currentSession: clearSession ? null : (currentSession ?? this.currentSession),
      selectedRegion: selectedRegion ?? this.selectedRegion,
    );
  }
}

// Notifier
class LobbyNotifier extends StateNotifier<LobbyState> {
  Timer? _timer;

  LobbyNotifier() : super(LobbyState(
    machines: [],
    occupiedCounts: {},
  )) {
    _initMockData();
  }

  void _initMockData() {
    // 构造更丰富的 Mock 数据
    final machines = [
      MachineModel(
        id: "bj_4090",
        name: "RTX 4090 旗舰",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/49d3e8c0-5403-4d43-9899-7333333f2022/w800",
        totalCount: 20,
        price: 8800,
        desc: "8K 60Hz · 极客专享",
        region: "华北-北京",
        ping: 12,
      ),
      MachineModel(
        id: "bj_4070s",
        name: "RTX 4070 Super",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/49d3e8c0-5403-4d43-9899-7333333f2022/w800",
        totalCount: 50,
        price: 3600,
        desc: "4K 144Hz · 光追全开",
        region: "华北-北京",
        ping: 15,
      ),
      MachineModel(
        id: "sh_4070s",
        name: "RTX 4070 Super",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/5b94f061-f308-4d50-934c-6f81878d2126/w800",
        totalCount: 80,
        price: 3600,
        desc: "4K 144Hz · 光追全开",
        region: "华东-上海",
        ping: 28,
      ),
      MachineModel(
        id: "sh_3070",
        name: "RTX 3070 Ti",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/5b94f061-f308-4d50-934c-6f81878d2126/w800",
        totalCount: 120,
        price: 2600,
        desc: "2K 高刷 · 电竞标准",
        region: "华东-上海",
        ping: 25,
      ),
      MachineModel(
        id: "gz_3060",
        name: "RTX 3060",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/97a54133-722a-4357-9943-28f000300957/w800",
        totalCount: 200,
        price: 1800,
        desc: "1080P · 畅玩网游",
        region: "华南-广州",
        ping: 45,
      ),
      MachineModel(
        id: "cd_2060",
        name: "RTX 2060",
        imageUrl: "https://dlcdnwebimgs.asus.com/gain/97a54133-722a-4357-9943-28f000300957/w800",
        totalCount: 150,
        price: 1200,
        desc: "入门体验 · 经济实惠",
        region: "西南-成都",
        ping: 52,
      ),
    ];

    final occupied = {
      "bj_4090": 18, // 爆满
      "bj_4070s": 32,
      "sh_4070s": 40,
      "sh_3070": 85,
      "gz_3060": 110,
      "cd_2060": 140, // 爆满
    };

    state = state.copyWith(machines: machines, occupiedCounts: occupied);
  }

  void setRegionFilter(String region) {
    state = state.copyWith(selectedRegion: region);
  }

  void startSession(String machineId) {
    final machine = state.machines.firstWhere((m) => m.id == machineId);
    final newOccupied = Map<String, int>.from(state.occupiedCounts);
    newOccupied[machineId] = (newOccupied[machineId] ?? 0) + 1;

    final session = GamingSession(
      machineId: machineId,
      machineName: machine.name,
      startTime: DateTime.now(),
      machineNo: "${machine.region.split('-')[1]}-${Random().nextInt(999)}",
    );

    state = state.copyWith(occupiedCounts: newOccupied, currentSession: session);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state; 
    });
  }

  void endSession() {
    if (state.currentSession == null) return;
    final machineId = state.currentSession!.machineId;
    
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
