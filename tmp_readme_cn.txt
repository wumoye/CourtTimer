# CourtTimer

[English](README.md) | [Chinese](README.zh-CN.md) | [Japanese](README.ja.md)

CourtTimer 是一个面向篮球训练/友谊赛的跨平台 Flutter 计时器应用。它提供可配置的比赛倒计时与自然的语音提示，让你专注于球场而不是码表。

## 功能
- 预设时长聚焦 6:00，另支持任意“自定义”时长。
- 开始前 3 秒（3-2-1）语音预备；恢复计时时跳过预备。
- 语音提醒节点可选（5/4/3/2/1 分钟、30 秒，且可自定义），并支持最后 10-0 逐秒倒计时。
- 计时运行中保持屏幕常亮。
- 设置面板可切换界面语言（中/英/日）与语音模式。
- 支持自定义结束音效（将音频放到 `assets/audio/` 并在设置里选择）。
- 记住上次语言、语音模式、时长、提醒节点、语速与哨声。
- 组件化的设置与显示样式，便于快速调整 UI。
- 支持 Android 与现代浏览器（Edge/Chrome）；桌面构建可用。

## 环境要求
- Flutter SDK >= 3.7.2
- Dart SDK（随 Flutter 安装）
- 视平台安装对应工具（Android SDK/ADB、浏览器、可选 Xcode 等）

## 快速开始
```bash
git clone https://github.com/<your-account>/courttimer.git
cd courttimer
flutter pub get
```

## 运行示例
```bash
# 连接的 Android 设备
flutter run -d <device-id>

# Web（Edge/Chrome）
flutter run -d edge

# Windows 桌面
flutter run -d windows
```

## 测试与质量
```bash
flutter analyze
flutter test
```

## 项目结构
```
lib/
  core/                      # 主题、设置控制器/Scope
  features/timer/
    controller/              # 业务逻辑（TimerController）
    model/                   # 状态与节点定义
    services/                # 语音与常亮服务
    presentation/
      pages/                 # 页面
      widgets/               # display/、settings/、dialogs/、common/
    utils/                   # 时间与语音格式化
```

## 更新说明（v1.1.1）
- 新增：语音提醒支持动态添加报时节点（“+”），默认提供 5/4/3/2/1 分钟与 30 秒。
- 优化：最后 10-0 逐秒倒计时改为串行播报，避免“10→9”抢播不顺。
- 优化：“下一把”按钮改为重置后直接开始新一局（含 3-2-1 预备）。
- 优化：语音提醒区域可折叠；页面布局在小屏避免溢出，底部留白更均衡。
- 精简：计时预设聚焦 6 分钟，其它请用“自定义”。
- 新增：语速滑杆（仅系统 TTS 生效），按语言给出安全默认值，可随时微调。
- 稳定性：设置面板高度/内边距优化；读取资源清单失败时兜底为空，避免红屏。
