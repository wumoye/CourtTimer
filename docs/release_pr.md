标题：首发准备：统一包名、签名与自动发布（APK + Play 用 AAB）并新增多语言文档与图标生成

概述
- 目标：合并 dev → main，完成首发前的所有底座工作。
- 变更核心：
  - CI：推送 `v*` 标签后自动构建 APK（通用 + 按 ABI）；AAB 用于 Google Play 上传，不作为 GitHub Release 下载附件。
  - 签名：本地 `android/key.properties` 与 GitHub Secrets 固定正式签名（支持覆盖升级）。
  - 包名：Android 使用 `com.wumoye.courttimer`，用于匹配 Google Play Console 已创建应用。
  - 显示名：统一为 `CourtTimer`（Android/iOS/macOS）。
  - 图标：支持 `assets/icon/icon.png` 自动生成启动图标（Android/iOS）。
  - 文档：新增中文/日文 README 与 `docs/signing.md`，完善“发布与下载”说明。

主要改动
- CI/CD
  - `.github/workflows/release.yml`：构建 APK（`app-release.apk` + 按 ABI 拆分）并上传到 Release；同时支持构建 AAB（`app-release.aab`）用于 Google Play 上传，但不作为 Release 附件分发。
- Android
  - `android/app/build.gradle.kts`：
    - `namespace` / `applicationId` → `com.wumoye.courttimer`
    - 引入 `key.properties` 的 release 签名；CI 注入 keystore 与 key.properties。
  - `android/app/src/main/AndroidManifest.xml`：`android:label` → `CourtTimer`
  - Kotlin 包结构：`android/app/src/main/kotlin/io/github/wumoye/courttimer/MainActivity.kt`
  - `.gitignore`：忽略 `android/release.keystore`、`android/key.properties`
- iOS
  - `ios/Runner.xcodeproj/project.pbxproj`：`PRODUCT_BUNDLE_IDENTIFIER` → `io.github.wumoye.courttimer`（含 RunnerTests）
  - `ios/Runner/Info.plist`：`CFBundleDisplayName`/`CFBundleName` → `CourtTimer`
- macOS
  - `macos/Runner/Configs/AppInfo.xcconfig`：`PRODUCT_NAME` → `CourtTimer`
  - `macos/Runner.xcodeproj/project.pbxproj`：RunnerTests 的 Bundle ID 同步为新前缀
- Linux
  - `linux/CMakeLists.txt`：`APPLICATION_ID` → `io.github.wumoye.courttimer`
- 图标与依赖
  - `pubspec.yaml`：新增 `flutter_launcher_icons`（dev dep）与相关配置，图标源为 `assets/icon/icon.png`
  - `assets/icon/README.txt`：放置说明
- 文档
  - `README.md`：语言导航（EN/中文/日文）
  - `README.zh-CN.md`、`README.ja.md`：新增并同步“发布与下载（APK）”“Google Play 用 AAB”与“固定正式签名”说明
  - `docs/signing.md`：签名与发布清单

重要说明 / 兼容性
- Android 包名已切换为 `com.wumoye.courttimer`，用于匹配 Google Play Console；如此前未对外发包，则无兼容问题。
- 首次发布前请确保 GitHub Secrets 已配置：
  - `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_ALIAS_PASSWORD`
- 可选：若提供 `assets/icon/icon.png`（1024×1024 PNG），CI 会在构建前自动生成 Android/iOS 图标。

验证与发布步骤
1) 可选：本地验证
   - `flutter pub get && dart run flutter_launcher_icons`（如有图标）
   - `flutter build apk --release`
   - `flutter build appbundle --release`
2) 合并到 main（本 PR）
3) 打标签触发发布
   - `git tag v1.0.0 && git push origin v1.0.0`
4) 产物查看
   - 打开对应标签的 GitHub Release，下载 `app-release.apk` 或按 ABI 拆分的 APK
   - `app-release.aab` 用于上传 Google Play，不建议作为 Release 附件给用户下载

后续可选
- 需要时可继续接入 Google Play 上传（r0adkll/upload-google-play）。
- Android 自适应图标/Android 13 单色图标可通过 `pubspec.yaml` 注释项启用。

