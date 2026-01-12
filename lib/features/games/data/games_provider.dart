import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game_model.dart';

final gamesProvider = FutureProvider<List<GameModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  try {
    // 暂时还是用 mock 数据演示，等真实数据生成
    final String jsonString = await rootBundle.loadString('assets/json/steam_games_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => GameModel.fromJson(e)).toList();
  } catch (e) {
    print("Error loading games: $e");
    return [];
  }
});

final gamesByCategoryProvider = Provider.family<AsyncValue<List<GameModel>>, String>((ref, category) {
  return ref.watch(gamesProvider).whenData((games) {
    if (category == "全部") return games;
    return games.where((g) => g.categories.contains(category)).toList();
  });
});
