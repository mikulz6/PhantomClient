# PhantomClient 集成与优化指南 (Flutter + Native Core)

本项目已整合 `mikulz6/PhantomClient` (Flutter UI), `qiin2333/foundation-sunshine` (服务端), `qiin2333/moonlight-vplus` (安卓核心), 及 `moonlight-qt` (PC核心)。

## 目录结构

*   `lib/`: **Flutter 前端**。你的自定义 UI 壳子。
*   `moonlight_core/`
    *   `Server/`: **服务端** (Based on FoundationSunshine)。含虚拟显示器驱动 (ZakoVDD)。
    *   `Client-Android/`: **安卓核心** (Based on Moonlight VPlus)。**已移除启动图标**，作为纯后端/核心模块存在。
    *   `Client-PC/`: **PC 核心** (Based on Moonlight QT)。保留备用。

## 架构设计：Flutter 壳 + Native 核

为了保证流媒体的极致性能 (低延迟解码/渲染)，我们采用 **Flutter 调起原生 Activity** 的混合模式，而不是将视频流直接渲染到 Flutter Widget 上。

### 1. 核心流程

1.  **UI 交互**：用户在 Flutter (`lib/`) 界面中进行服务器发现、配对、游戏列表选择。
    *   *实现方式*：Flutter 通过 `MethodChannel` 调用 `Client-Android` 中的 Java 接口 (`ComputerManagerService`, `DiscoveryService`) 获取数据。
2.  **启动串流**：用户点击“开始游戏”。
3.  **切换原生**：Flutter 发送指令，启动 `Client-Android` 中的 `com.limelight.Game` Activity。
    *   这个 Activity 是 Moonlight VPlus 经过优化的核心，包含硬解、EasyTier VPN、输入驱动等。
    *   *修改点*：该 Activity 运行在独立进程或顶层，接管屏幕。
4.  **结束串流**：用户关闭游戏，`Game` Activity 结束，返回 Flutter 界面。

### 2. 如何集成 (Android)

由于 `Client-Android` 原本是一个完整的 App，为了与 Flutter 融合，你需要：

1.  **Gradle 配置**：
    在你的 Flutter 项目的 `android/settings.gradle` 中包含 `moonlight_core/Client-Android` 模块。
    ```gradle
    include ':moonlight_core:Client-Android:app'
    project(':moonlight_core:Client-Android:app').projectDir = new File(settingsDir, '../moonlight_core/Client-Android/app')
    ```

2.  **依赖引用**：
    在 `android/app/build.gradle` 中依赖它：
    ```gradle
    implementation project(path: ':moonlight_core:Client-Android:app')
    ```
    *注意：可能需要将 Client-Android 的 `com.android.application` 改为 `com.android.library`，并移除 `applicationId`。如果保留 application 插件，则需作为多模块应用处理。*

3.  **MethodChannel 对接**：
    在 `lib/` 中编写 Dart 代码，通过 Platform Channel 调用 `com.limelight` 包下的逻辑。

### 3. 已完成的优化

*   **VPlus 后端耦合**：`Client-Android` 完整保留了 VPlus 的 EasyTier、虚拟显示器适配代码。
*   **去 UI 化**：修改了 `AndroidManifest.xml`，移除了 `PcView` 的 Launcher 入口。现在安装后不会在桌面显示两个图标，必须由你的 Flutter 应用主动拉起。

### 4. 服务端 (Server)

位于 `moonlight_core/Server`。请在部署目标机器（云电脑）上编译运行此目录下的代码。它已经包含了对 Client-Android 虚拟显示器请求的响应逻辑。
