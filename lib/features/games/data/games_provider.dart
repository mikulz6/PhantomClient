import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game_model.dart';

// 基础 Provider：加载所有游戏
final gamesProvider = FutureProvider<List<GameModel>>((ref) async {
  // 模拟加载延迟，增加真实感
  await Future.delayed(const Duration(milliseconds: 500));
  
  try {
    final String jsonString = await rootBundle.loadString('assets/json/steam_games_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => GameModel.fromJson(e)).toList();
  } catch (e) {
    print("Error loading games: $e");
    return [];
  }
});

// 衍生 Provider：热销榜 (前10)
final topSellersProvider = Provider<AsyncValue<List<GameModel>>>((ref) {
  return ref.watch(gamesProvider).whenData((games) => games.take(10).toList());
});

// 衍生 Provider：按分类过滤
final gamesByCategoryProvider = Provider.family<AsyncValue<List<GameModel>>, String>((ref, category) {
  return ref.watch(gamesProvider).whenData((games) {
    // 模糊匹配
    if (category == "全部") return games;
    return games.where((g) => g.tags.any((tag) => tag.contains(category)) || g.category == category).toList();
  });
});
