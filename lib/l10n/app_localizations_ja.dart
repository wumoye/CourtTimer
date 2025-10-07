// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'コートタイマー';

  @override
  String get timerPageTitle => 'タイマー';

  @override
  String get announcementSectionTitle => 'アナウンス';

  @override
  String get resetButtonLabel => 'リセット';

  @override
  String get customDurationAction => 'カスタム';

  @override
  String get finalCountdownLabel => '10〜0 カウントダウン';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguageLabel => '言語';

  @override
  String get settingsSpeechModeLabel => '音声モード';

  @override
  String get settingsEndSoundLabel => '終了サウンド';

  @override
  String get speechModeSystem => '端末TTS（オフライン）';

  @override
  String get speechModeOffline => '音声パック（近日対応）';

  @override
  String get speechModeOnline => 'オンラインTTS（近日対応）';

  @override
  String get speechModeUnavailableNote => 'その他の音声モードは今後追加予定です。';

  @override
  String get settingsSpeechModeHelp => 'アナウンス方法を選択してください。';

  @override
  String get settingsEndSoundHelp => '試合終了時に再生するホイッスルを選択。';

  @override
  String get endSoundNoneOption => 'なし';

  @override
  String get endSoundPreviewPlay => '試聴';

  @override
  String get endSoundPreviewStop => '停止';

  @override
  String get endSoundPreviewError => 'サウンドを再生できません。';

  @override
  String get languageChinese => '中国語';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get customDurationTitle => 'カスタム時間';

  @override
  String get customMinutesLabel => '分';

  @override
  String get customSecondsLabel => '秒';

  @override
  String customMinutesSliderLabel(int minutes) {
    return '$minutes 分';
  }

  @override
  String customSecondsSliderLabel(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get customMinutesSuffix => '分';

  @override
  String get customSecondsSuffix => '秒';

  @override
  String customMinutesValidator(int max) {
    return '0〜$max を入力';
  }

  @override
  String get customSecondsValidator => '0〜59 を入力';

  @override
  String get customDurationZeroError => '合計時間は 0 より大きくしてください';

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get dialogConfirm => '決定';

  @override
  String get timerDisplayPrestart => '準備';

  @override
  String get timerDisplayRunning => 'タップで一時停止 / 長押しでリセット';

  @override
  String get timerDisplayCompleted => 'タップで開始 / 長押しでリセット';

  @override
  String get timerDisplayIdle => 'タップで開始 / 長押しでリセット';

  @override
  String get timerDisplayOverlayCompleted => '試合終了';
}
