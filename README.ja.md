# CourtTimer

[English](README.md) | [简体中文](README.zh-CN.md) | 日本語

CourtTimer は、バスケットボールの練習やスクリメージ向けに設計されたクロスプラットフォームの Flutter 製タイマーアプリです。設定可能なゲームクロックと自然な音声アナウンスで、ストップウォッチ操作から解放します。

## 特長
- プリセット時間（6:00 / 1:00 / 0:30）に加え、自由なインターバル設定。
- 開始前の 3-2-1 カウントダウン（リセット再開時はスキップ可）。
- 120s / 60s / 30s の節目アナウンスと、任意の 10→0 カウントダウン。
- タイマー動作中の画面スリープ抑止。
- クイック設定から UI 言語（ZH/EN/JA）と音声モードを切替。
- 笛音は `assets/audio/` に音源を配置して選択可能。
- 言語・音声モード・時間・マイルストーン・笛音などを保存。
- デスクトップ（Windows/macOS/Linux）もビルド可能。

## 必要環境
- Flutter SDK ≥ 3.7.2（同梱の Dart を使用）
- プラットフォームごとのツール類（Android SDK / Chrome など）

## はじめかた
```bash
git clone https://github.com/<your-account>/courttimer.git
cd courttimer
flutter pub get
```

## 実行方法
```bash
# Android
flutter run -d <device-id>

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

## テスト
```bash
flutter analyze
flutter test
```

## 配布とダウンロード（Android・個人配布）
- タグ `v*` を push すると、GitHub Actions が自動ビルド＆Release 作成（APK を出力）：
  - 例：`git tag v1.0.0 && git push origin v1.0.0`
  - ビルド番号付き：`git tag v1.0.0+2 && git push origin v1.0.0+2`
- Release の Assets：
  - `app-release.apk`：汎用 APK（配布に最適）
  - `app-*-release.apk`：ABI 別 APK（サイズ小）
- インストールの注意：
  - 初回は「提供元不明のアプリ」を許可、またはブラウザ/ファイルアプリにインストール権限を付与。
  - アップデートには同一署名が必要。未設定の場合は CI がデバッグ署名でビルド。将来的には release 署名の固定化を推奨（下記参照）。

## リリース署名の固定（Android）
配布用 APK/AAB を、長期的に同一の keystore（秘密鍵）と alias で署名し続ける運用です：
- メリット：
  - 端末上書きインストール（アップデート）には署名一致が必須。
  - 出所の一貫性・信頼性を担保。
- 手順（初回設定）：
  1) keystore 生成：`keytool -genkeypair -v -keystore release.keystore -alias <alias> -keyalg RSA -keysize 2048 -validity 36500`
  2) `android/key.properties` に以下を保存：
     ```
     storePassword=<keystoreのパスワード>
     keyPassword=<aliasのパスワード>
     keyAlias=<alias>
     storeFile=release.keystore
     ```
  3) CI の Secrets に同情報を登録：
     `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_ALIAS_PASSWORD`
  4) 本リポジトリは `key.properties` を自動読込して release 署名を設定。CI でも同様に注入後ビルド。
- 注意：keystore を紛失すると旧パッケージへの上書き更新が不可になります（パッケージ名変更 or 再インストールが必要）。

## iOS の個人利用
- Mac の Xcode で `ios/Runner.xcworkspace` を開き、Team と Bundle ID を設定。
- iPhone を接続してそのまま Run/Install（無料アカウントも可。ただし有効期間が短い）。
- 他者配布は Ad Hoc（UDID 収集）や TestFlight（開発者アカウント要）が必要になるため、本リポジトリは既定では対象外。
