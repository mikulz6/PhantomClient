import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game_model.dart';

final gamesProvider = FutureProvider<List<GameModel>>((ref) async {
  // 模拟加载延迟
  await Future.delayed(const Duration(milliseconds: 300));
  
  try {
    final String jsonString = await rootBundle.loadString('assets/json/steam_games_data_mock.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => GameModel.fromJson(e)).toList();
  } catch (e) {
    print("Error loading games: $e");
    return [];
  }
});

final topSellersProvider = Provider<AsyncValue<List<GameModel>>>((ref) {
  // 热销榜直接取前 100
  return ref.watch(gamesProvider).whenData((games) => games.take(100).toList());
});

final gamesByCategoryProvider = Provider.family<AsyncValue<List<GameModel>>, String>((ref, category) {
  return ref.watch(gamesProvider).whenData((games) {
    if (category == "全部") return games;
    // 直接匹配预计算的 category 字段，性能更高
    return games.where((g) => g.category == category).toList();
  });
});
