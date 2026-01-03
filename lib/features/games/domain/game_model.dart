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
  
  late final GamePerformance performance;
  final List<String> categories; // 修改为列表

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
    required this.categories,
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
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class GamePerformance {
  final int fps2060;
  final int fps3070;
  final int fps4070s;
  
  // 增加 CPU 信息
  final String cpu2060;
  final String cpu3070;
  final String cpu4070s;

  GamePerformance({
    required this.fps2060,
    required this.fps3070,
    required this.fps4070s,
    this.cpu2060 = "AMD Ryzen 5 3600",
    this.cpu3070 = "AMD Ryzen 5 3600",
    this.cpu4070s = "AMD Ryzen 5 5600X",
  });
}

class GamePerformanceCalculator {
  static GamePerformance estimate(String name, List<String> tags, String date) {
    int baseFps = 60;
    bool isAAA = tags.contains("动作") || tags.contains("冒险") || tags.contains("RPG");
    
    if (name.contains("Cyberpunk") || name.contains("Wukong")) {
       baseFps = 45; 
    } else if (tags.contains("独立") || tags.contains("2D")) {
       baseFps = 100; 
    }

    return GamePerformance(
      fps2060: baseFps,
      fps3070: (baseFps * 1.6).toInt(),
      fps4070s: (baseFps * 2.2).toInt(),
    );
  }
}
