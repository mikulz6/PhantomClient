# Cloud Gaming Client (Re-imagined Moonlight)

这是一个基于 Flutter + Dart 重构的商业级云游戏客户端。我们的目标是将 Moonlight 从一个“极客工具”转化为一个面向普通用户的、拥有极致体验的云游戏服务入口。

## 🎯 产品定位

*   **去工具化**：隐藏复杂的串流参数（码率、编码格式等），后端自动调度。
*   **商业化**：内置金币体系、签到、充值和机型租赁逻辑。
*   **视觉升级**：采用 Apple + PlayStation 5 的设计语言（深色模式、磨砂玻璃、丝滑交互）。

## 🏗 技术栈

*   **Frontend**: Flutter (Dart)
*   **State Management**: Riverpod
*   **Navigation**: GoRouter
*   **UI/Effects**: Flutter Animate, Glass Kit
*   **Networking**: Dio

## 📂 项目结构

```
lib/
  core/           # 核心配置 (Theme, Router, Constants)
  features/       # 业务模块
    games/        # 游戏库 (Steam 风格展示)
    lobby/        # 大厅/机器选择 (商业化核心)
    profile/      # 个人中心 (金币、充值)
  shared/         # 共享组件 (Widgets)
  main.dart       # 入口
```

## 🚀 快速开始

1.  确保本地已安装 Flutter SDK (3.x+)。
2.  克隆本项目。
3.  运行依赖安装：
    ```bash
    flutter pub get
    ```
4.  启动项目：
    ```bash
    flutter run
    ```

## 🎨 设计规范

*   **色彩**：以深灰/午夜蓝 (`#0F1115`) 为背景，搭配电光蓝 (`#3D7AF0`) 作为强调色。
*   **排版**：Inter / 系统默认无衬线字体，强调层级感。
*   **交互**：所有点击必须有反馈，页面切换使用平滑过渡。

## 📝 待办事项

- [x] 初始化项目结构与主题
- [x] 实现底部导航架构
- [x] 完成“游戏”页 UI 骨架
- [x] 完成“大厅”页 UI 骨架
- [x] 完成“我的”页 UI 骨架
- [ ] 对接后端 API
- [ ] 集成 Moonlight 串流核心 (C++/JNI)
- [ ] 实现充值与支付逻辑
- [ ] 添加看板娘动画

---
*Based on Moonlight Open Source Project*
