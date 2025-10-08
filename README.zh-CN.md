# CourtTimer

[English](README.md) | 简体中文 | [日本語](README.ja.md)

CourtTimer 是一个面向篮球训练/友谊赛的跨平台 Flutter 计时器应用。它提供可配置的比赛时钟和自然语音提示，让大家专注在球场而不是秒表。

## 特性
- 预设时长（6:00 / 1:00 / 0:30）+ 支持自定义任意间隔。
- 开始前 3 秒倒计时（3-2-1），复位后可跳过预倒计时。
- 关键里程语音提醒（120s / 60s / 30s），以及可选的最后 10→0 倒计时。
- 计时运行时保持屏幕常亮。
- 快捷设置里可切换 UI 语言（中文/英文/日文）与语音模式。
- 结哨音可自定义：将音频放到 `assets/audio/` 并在设置中选择。
- 记忆语言、语音模式、时长、里程碑和哨音等设置。
- 结构化组件，便于主题和 UI 调整。
- 支持 Android、Web、桌面（Windows/macOS/Linux）。

## 环境要求
- Flutter SDK ≥ 3.7.2
- Dart SDK（随 Flutter 安装）
- 平台依赖：
  - Android：Android Studio 或命令行 Android SDK + ADB
  - Web：Chrome/Edge
  - iOS（可选）：macOS + Xcode

## 快速开始
```bash
git clone https://github.com/<your-account>/courttimer.git
cd courttimer
flutter pub get
```

## 运行应用
```bash
# Android（示例设备）
flutter run -d <device-id>

# Web
flutter run -d chrome

# Windows 桌面
flutter run -d windows
```

## 测试与质量
```bash
flutter analyze
flutter test
```

## 项目结构（简）
```
lib/
  core/                      # 主题、设置
  features/timer/            # 业务与 UI（计时器、设置、组件等）
test/                        # Widget 测试
```

## 发布与下载（Android，自用/分享）
- 触发发布：推送形如 `v*` 的标签后，GitHub Actions 会自动构建并创建 Release，附带 APK 安装包。
  - 示例：`git tag v1.0.0 && git push origin v1.0.0`
  - 可带构建号：`git tag v1.0.0+2 && git push origin v1.0.0+2`
- 在 GitHub Releases 对应标签页下载：
  - `app-release.apk`：通用 APK（推荐直接分享安装）。
  - `app-*-release.apk`：按 ABI 拆分的 APK（体积更小，可选）。
- 安卓安装提示：
  - 首次安装需允许“未知来源应用”或为浏览器/文件管理器授予安装权限。
  - 覆盖安装需要相同签名。未配置签名时，CI 会使用调试签名；建议后续固定 release 签名（见下文“固定正式签名”）。

## 固定正式签名（Android）
“固定正式签名”指为发布用的 APK/AAB 设置一把长期不变的 keystore（私钥）与 alias，并在本地与 CI 中始终使用它来签名构建：
- 为什么要固定？
  - 覆盖安装：同包名的应用，只有在“签名一致”时才能直接覆盖升级。
  - 信任与溯源：相同签名便于用户与系统识别“确实是你发布的更新”。
- 如何固定（一次性配置）：
  1) 生成 keystore：`keytool -genkeypair -v -keystore release.keystore -alias <alias> -keyalg RSA -keysize 2048 -validity 36500`
  2) 在本地 `android/key.properties` 写入：
     ```
     storePassword=<keystore密码>
     keyPassword=<alias密码>
     keyAlias=<alias>
     storeFile=release.keystore
     ```
  3) CI 中以 Secrets 形式保存同一套信息：
     - `ANDROID_KEYSTORE_BASE64`：`release.keystore` 的 Base64
     - `ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_ALIAS_PASSWORD`
  4) 我们已在 `android/app/build.gradle.kts` 里自动读取 `key.properties` 并用于 release 签名；在 CI 中，工作流会写入相同文件后再构建。
- 注意：一旦用于对外分发，请妥善保管 keystore；丢失将无法为旧安装包提供可覆盖升级的更新（需要更换包名或卸载重装）。

## iOS 自用（不经商店）
- 使用你的 Mac：Xcode 打开 `ios/Runner.xcworkspace`，设置 Team 和唯一 Bundle ID。
- 连接 iPhone，直接 Run/Install 到设备（免费账号可用，但证书有效期较短）。
- 给他人安装而不走商店通常需要 Ad Hoc（收集对方 UDID）或 TestFlight（需开发者账号），本仓库默认不包含该流程。
