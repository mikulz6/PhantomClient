package com.mikulz.phantom

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.limelight.Game
import com.limelight.PcView // 引用 VPlus 的类

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mikulz.phantom/core"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "findComputers" -> {
                    // TODO: 集成真实的发现逻辑。
                    // 暂时返回一个空列表或 Mock 数据，证明通道打通。
                    // VPlus 的发现逻辑比较复杂，通常涉及后台 Service。
                    // 在这里我们先做一个简单的占位。
                    result.success(listOf<Map<String, Any>>())
                }
                "startGame" -> {
                    // 启动串流核心 Activity
                    try {
                        // 这里的 Intent 参数需要根据 VPlus 的 Game Activity 接收的参数来构造
                        // 通常需要传递主机 IP, AppID 等
                        val intent = Intent(this, Game::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        
                        // 从 flutter 传入参数
                        val host = call.argument<String>("host")
                        val appId = call.argument<Int>("appId")
                        
                        // 根据 Moonlight 的逻辑填充 Intent Extra
                        // 这里假设 Game 需要特定的 Extra
                        // intent.putExtra("host", host)
                        // intent.putExtra("appId", appId)
                        
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("START_FAILED", e.message, null)
                    }
                }
                "openLegacyUi" -> {
                    // 调试用：打开原版 VPlus 的界面
                    val intent = Intent(this, PcView::class.java)
                    startActivity(intent)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
