import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.mikulz.phantom/core');

  /// 搜索电脑 (目前返回 Raw Data)
  static Future<List<dynamic>> findComputers() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('findComputers');
      return result;
    } on PlatformException catch (e) {
      print("Failed to find computers: '${e.message}'.");
      return [];
    }
  }

  /// 启动串流
  /// [host]: 电脑 IP 或主机名
  /// [appId]: 游戏 ID
  static Future<void> startGame(String host, int appId) async {
    try {
      await _channel.invokeMethod('startGame', {
        'host': host,
        'appId': appId,
      });
    } on PlatformException catch (e) {
      print("Failed to start game: '${e.message}'.");
    }
  }
  
  /// 调试：打开旧版 VPlus 界面
  static Future<void> openLegacyUi() async {
    await _channel.invokeMethod('openLegacyUi');
  }
}
