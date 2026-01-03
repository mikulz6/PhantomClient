import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../domain/game_model.dart';

class FpsChart extends StatelessWidget {
  final GamePerformance performance;

  const FpsChart({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // 白底
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)), // 极淡边框
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildBar("RTX 2060", performance.fps2060, Colors.grey),
          const SizedBox(height: 16),
          _buildBar("RTX 3070", performance.fps3070, AppColors.primary),
          const SizedBox(height: 16),
          _buildBar("RTX 4070S", performance.fps4070s, Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int fps, Color color) {
    final double percentage = (fps / 200).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary), // 深灰字
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // 背景槽
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1), // 浅灰槽
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // 进度条
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
                    ],
                  ),
                ),
              ).animate().slideX(duration: 800.ms, curve: Curves.easeOutQuart),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 60,
          child: Text(
            "$fps FPS",
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 500.ms),
        ),
      ],
    );
  }
}
