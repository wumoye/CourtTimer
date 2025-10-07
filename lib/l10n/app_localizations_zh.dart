// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'CourtTimer 计时器';

  @override
  String get timerPageTitle => '计时器';

  @override
  String get announcementSectionTitle => '语音提醒';

  @override
  String get resetButtonLabel => '下一把';

  @override
  String get customDurationAction => '自定义';

  @override
  String get finalCountdownLabel => '10~0 秒倒数';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageLabel => '界面语言';

  @override
  String get settingsSpeechModeLabel => '语音模式';

  @override
  String get settingsEndSoundLabel => '结束音效';

  @override
  String get speechModeSystem => '系统语音（离线）';

  @override
  String get speechModeOffline => '语音包（敬请期待）';

  @override
  String get speechModeOnline => '在线语音（敬请期待）';

  @override
  String get speechModeUnavailableNote => '其他语音模式将在未来版本提供。';

  @override
  String get settingsSpeechModeHelp => '选择语音播报的方案。';

  @override
  String get settingsEndSoundHelp => '选择计时结束时播放的哨声或提示音。';

  @override
  String get endSoundNoneOption => '无';

  @override
  String get endSoundPreviewPlay => '预览';

  @override
  String get endSoundPreviewStop => '停止';

  @override
  String get endSoundPreviewError => '无法播放音频。';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageJapanese => '日文';

  @override
  String get customDurationTitle => '自定义倒计时';

  @override
  String get customMinutesLabel => '分钟';

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
    return '请输入 0-$max';
  }

  @override
  String get customSecondsValidator => '请输入 0-59';

  @override
  String get customDurationZeroError => '倒计时时长必须大于 0';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogConfirm => '确定';

  @override
  String get timerDisplayPrestart => '预备';

  @override
  String get timerDisplayRunning => '轻触暂停 / 长按重置';

  @override
  String get timerDisplayCompleted => '轻触开始 / 长按重置';

  @override
  String get timerDisplayIdle => '轻触开始 / 长按重置';

  @override
  String get timerDisplayOverlayCompleted => '已结束';
}
