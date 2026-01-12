import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/game_model.dart';

final gamesProvider = FutureProvider<List<GameModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  
  // 优先尝试加载本地 JSON 文件
  try {
    final String jsonString = await rootBundle.loadString('assets/json/steam_games_data.json');
    if (jsonString.isNotEmpty) {
      final List<dynamic> jsonList = json.decode(jsonString);
      if (jsonList.isNotEmpty) {
        return jsonList.map((e) => GameModel.fromJson(e)).toList();
      }
    }
  } catch (e) {
    print("Local JSON not found or empty, falling back to Hardcoded Mock Data.");
  }

  // 如果本地文件不存在或为空，使用以下高质量 Mock 数据
  // 这些 URL 都是公开可访问的高清图
  return [
    GameModel(
      id: 2358720,
      name: "Black Myth: Wukong",
      shortDescription: "《黑神话：悟空》是一款以中国神话为背景的动作角色扮演游戏。你将扮演一位“天命人”，为了探寻昔日传说的真相，踏上条充满危险与惊奇的西游之路。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/2358720/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/2358720/library_600x900.jpg",
      videoUrl: "",
      tags: ["动作", "角色扮演", "魂类", "神话"],
      priceText: "¥ 268",
      releaseDate: "2024年8月20日",
      categories: ["动作", "ARPG", "魂与类魂"],
    ),
    GameModel(
      id: 1091500,
      name: "Cyberpunk 2077",
      shortDescription: "《赛博朋克 2077》的舞台位于大都会夜之城，是一款在开放世界动作冒险角色扮演游戏。您扮演一位赛博朋克雇佣兵 V，在这座巨型城市中寻找一种独一无二的植入体。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/1091500/library_600x900.jpg",
      videoUrl: "",
      tags: ["赛博朋克", "开放世界", "科幻", "RPG"],
      priceText: "¥ 298",
      releaseDate: "2020年12月10日",
      categories: ["开放世界", "射击游戏", "赛博朋克"],
    ),
    GameModel(
      id: 1245620,
      name: "ELDEN RING",
      shortDescription: "本作为以正统黑暗奇幻世界为舞台的动作RPG游戏。 走进辽阔的场景与地下迷宫探索未知，挑战困难重重的险境，享受克服困境时的成就感吧。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/1245620/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/1245620/library_600x900.jpg",
      videoUrl: "",
      tags: ["魂类", "开放世界", "黑暗奇幻", "困难"],
      priceText: "¥ 298",
      releaseDate: "2022年2月25日",
      categories: ["ARPG", "魂与类魂", "开放世界"],
    ),
    GameModel(
      id: 1174180,
      name: "Red Dead Redemption 2",
      shortDescription: "Red Dead Redemption 2 已荣获超过 175 项年度游戏奖项且获得超过 250 个满分评价，游戏中述说亚瑟·摩根和范德林德帮派的传奇故事，体验在 19 世纪的最后岁月里横跨美国的亡命之旅。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/1174180/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/1174180/library_600x900.jpg",
      videoUrl: "",
      tags: ["开放世界", "剧情丰富", "西部", "射击"],
      priceText: "¥ 279",
      releaseDate: "2019年12月6日",
      categories: ["开放世界", "射击游戏", "Rockstar"],
    ),
    GameModel(
      id: 570,
      name: "Dota 2",
      shortDescription: "每天都有数百万玩家化为一百余名Dota英雄展开大战。不论是游戏时间刚满10小时还是1000小时，比赛中总能找到新鲜感。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/570/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/570/library_600x900.jpg",
      videoUrl: "",
      tags: ["MOBA", "多人", "策略", "免费"],
      priceText: "免费",
      releaseDate: "2013年7月9日",
      categories: ["策略模拟", "网游", "免费游戏"],
    ),
    GameModel(
      id: 271590,
      name: "Grand Theft Auto V",
      shortDescription: "PC 版 Grand Theft Auto V 能够以超越 4K 的最高分辨率和 60 帧每秒的帧率，为您呈现屡获殊荣、令人痴迷的游戏世界——洛圣都和布雷恩郡。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/271590/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/271590/library_600x900.jpg",
      videoUrl: "",
      tags: ["开放世界", "犯罪", "动作", "多人"],
      priceText: "¥ 148",
      releaseDate: "2015年4月14日",
      categories: ["开放世界", "射击游戏", "Rockstar"],
    ),
     GameModel(
      id: 1086940,
      name: "Baldur's Gate 3",
      shortDescription: "召集你的队伍，返回被遗忘的国度，开启一段记载着友谊与背叛、牺牲与生存、以及至上权力诱惑的传奇故事。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/1086940/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/1086940/library_600x900.jpg",
      videoUrl: "",
      tags: ["RPG", "策略", "龙与地下城", "剧情丰富"],
      priceText: "¥ 298",
      releaseDate: "2023年8月3日",
      categories: ["ARPG", "策略模拟", "Larian"],
    ),
    GameModel(
      id: 262060,
      name: "Darkest Dungeon®",
      shortDescription: "Darkest Dungeon是一个极具挑战性的哥特式类Rogue回合制RPG，聚焦冒险的心理压力。招募、训练和领导一队有缺点的英雄，穿行扭曲的森林、被遗忘的巢穴、毁坏的地窟等地。",
      headerImage: "https://cdn.akamai.steamstatic.com/steam/apps/262060/header.jpg",
      posterImage: "https://cdn.akamai.steamstatic.com/steam/apps/262060/library_600x900.jpg",
      videoUrl: "",
      tags: ["回合制", "类Rogue", "黑暗奇幻", "困难"],
      priceText: "¥ 78",
      releaseDate: "2016年1月19日",
      categories: ["独立佳作", "策略模拟", "肉鸽莱克"],
    ),
  ];
});

final gamesByCategoryProvider = Provider.family<AsyncValue<List<GameModel>>, String>((ref, category) {
  return ref.watch(gamesProvider).whenData((games) {
    if (category == "全部") return games;
    return games.where((g) => g.categories.contains(category)).toList();
  });
});
