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
  final String category; // 现在直接从 JSON 读取

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
    required this.category,
  }) {
    performance = GamePerformanceCalculator.estimate(name, tags, releaseDate);
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
      category: json['category'] as String? ?? "其他", // 读取预计算的分类
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
    int baseFps = 60;
    
    // 简单的估算逻辑
    bool isAAA = tags.contains("动作") || tags.contains("冒险") || tags.contains("RPG") || tags.contains("竞速");
    if (name.contains("Cyberpunk") || name.contains("Red Dead") || name.contains("Elden Ring") || name.contains("Wukong")) {
       baseFps = 45; 
    } else if (tags.contains("独立") || tags.contains("模拟") || tags.contains("2D")) {
       baseFps = 100; 
    }

    return GamePerformance(
      baseFps,
      (baseFps * 1.6).toInt(),
      (baseFps * 2.2).toInt(),
    );
  }
}
