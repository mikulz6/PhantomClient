import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<String> tags;

  // 同样的浅色荧光色板
  static const List<Color> _neonColors = [
    Color(0xFF00FFCC), // 荧光青
    Color(0xFFFF66CC), // 荧光粉
    Color(0xFFCCFF00), // 荧光柠
    Color(0xFF00FFFF), // 电光蓝
    Color(0xFFFF9966), // 珊瑚橙
    Color(0xFFCC99FF), // 薰衣草
    Color(0xFF66FF99), // 薄荷绿
  ];

  const GameCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 游戏封面
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceLight,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceLight,
                    child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                  ),
                ),
                // 渐变遮罩
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 游戏信息
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                // 标签行
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.map((tag) => _buildNeonTag(tag)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTag(String text) {
    final color = _neonColors[text.hashCode.abs() % _neonColors.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: Colors.black, // 黑色文字
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
