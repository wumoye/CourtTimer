标题：Android 签名与发布清单

适用范围：本仓库（CourtTimer）的 Android 自用/分享式发布；目标是“固定正式签名”，保证后续 APK 可覆盖升级。

一、确定包名（一次）
- Android：`android/app/build.gradle.kts` 中 `applicationId`
- 本仓库已设置为：`io.github.wumoye.courttimer`

二、生成正式 keystore（一次）
- PowerShell（Windows）：
  - `keytool -genkeypair -v -keystore .\release.keystore -alias <alias> -keyalg RSA -keysize 2048 -validity 36500`
- macOS/Linux：
  - `keytool -genkeypair -v -keystore release.keystore -alias <alias> -keyalg RSA -keysize 2048 -validity 36500`

三、本地配置 key.properties（不提交到 Git）
- 创建文件：`android/key.properties`
```
storePassword=<keystore密码>
keyPassword=<alias密码>
keyAlias=<alias>
# 注意：Gradle 在 app 模块解析相对路径，这里用 ../ 指向 android/ 目录下的 keystore
storeFile=../release.keystore
```
- 将 `release.keystore` 放在 `android/` 目录。
- `.gitignore` 已忽略 `android/release.keystore` 与 `android/key.properties`。

四、配置 GitHub Actions Secrets（用于 CI）
- 计算 keystore Base64（PowerShell）：
  - `[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.keystore"))`
- 在仓库 Settings → Secrets and variables → Actions 新增：
  - `ANDROID_KEYSTORE_BASE64`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_ALIAS_PASSWORD`

五、构建与分发
- 本地验证：`flutter build apk --release`
- CI 触发发布：
  - `git tag v1.0.0 && git push origin v1.0.0`
  - 产物位于 GitHub Release 的 Assets：
    - `app-release.apk`（通用包）
    - `app-*-release.apk`（按 ABI 拆分）

注意事项
- 一旦启动对外分发，请妥善保管 keystore；丢失将无法覆盖升级（需要更换包名或让用户卸载重装）。
- 首发前确定好包名；后续不要更改 `applicationId`。
