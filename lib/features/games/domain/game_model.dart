import 'dart:convert';

class GameModel {
  final int id;
  final String name;
  final String shortDescription;
  final String headerImage;
  final String posterImage;
  final String videoUrl;
  final List<String> tags;
  final String priceText;
  final String releaseDate;
  
  // 额外计算的属性
  late final GamePerformance performance;
  late final String category; // 二次分类

  GameModel({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.headerImage,
    required this.posterImage,
    required this.videoUrl,
    required this.tags,
    required this.priceText,
    required this.releaseDate,
  }) {
    performance = GamePerformanceCalculator.estimate(name, tags, releaseDate);
    category = GameCategoryClassifier.classify(name, tags);
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as int,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String? ?? "",
      headerImage: json['header_image'] as String,
      posterImage: json['poster_image'] as String,
      videoUrl: json['video_url'] as String? ?? "",
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      priceText: json['price_text'] as String? ?? "免费",
      releaseDate: json['release_date'] as String? ?? "",
    );
  }
}

class GamePerformance {
  final int fps2060;
  final int fps3070;
  final int fps4070s;

  GamePerformance(this.fps2060, this.fps3070, this.fps4070s);
}

class GamePerformanceCalculator {
  static GamePerformance estimate(String name, List<String> tags, String date) {
    // 简单的估算逻辑，模拟真实感
    int baseFps = 60;
    
    // 1. 根据标签判断是否是大型游戏
    bool isAAA = tags.contains("动作") || tags.contains("冒险") || tags.contains("RPG") || tags.contains("竞速");
    if (name.contains("Cyberpunk") || name.contains("Red Dead") || name.contains("Elden Ring") || name.contains("Wukong")) {
       baseFps = 45; // 显卡杀手基准
    } else if (tags.contains("独立") || tags.contains("模拟")) {
       baseFps = 100; // 轻量级
    }

    // 2. 模拟三档显卡的性能阶梯
    // 2060 作为基准 (1.0x)
    // 3070 约为 1.6x
    // 4070s 约为 2.2x
    
    return GamePerformance(
      baseFps,
      (baseFps * 1.6).toInt(),
      (baseFps * 2.2).toInt(),
    );
  }
}

class GameCategoryClassifier {
  static String classify(String name, List<String> tags) {
    // 简单关键词分类
    if (tags.contains("竞速") || name.contains("Forza")) return "竞速狂飙";
    if (tags.contains("角色扮演") || name.contains("Ring") || name.contains("Fantasy")) return "RPG";
    if (tags.contains("射击") || name.contains("Call of Duty") || name.contains("CS") || name.contains("Apex")) return "FPS/TPS";
    if (tags.contains("独立")) return "独立佳作";
    return "热门精选";
  }
}
