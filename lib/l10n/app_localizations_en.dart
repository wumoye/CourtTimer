// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Court Timer';

  @override
  String get timerPageTitle => 'Clock';

  @override
  String get announcementSectionTitle => 'Announcements';

  @override
  String get resetButtonLabel => 'Reset';

  @override
  String get customDurationAction => 'Custom';

  @override
  String get finalCountdownLabel => '10-0 final countdown';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsSpeechModeLabel => 'Speech mode';

  @override
  String get settingsEndSoundLabel => 'End sound';

  @override
  String get speechModeSystem => 'Device TTS (offline)';

  @override
  String get speechModeOffline => 'Audio pack (offline, coming soon)';

  @override
  String get speechModeOnline => 'Online TTS (coming soon)';

  @override
  String get speechModeUnavailableNote => 'Other speech modes will be available in a future update.';

  @override
  String get settingsSpeechModeHelp => 'Choose how announcements are spoken.';

  @override
  String get settingsEndSoundHelp => 'Choose the whistle or alert to play when time expires.';

  @override
  String get endSoundNoneOption => 'None';

  @override
  String get endSoundPreviewPlay => 'Preview';

  @override
  String get endSoundPreviewStop => 'Stop';

  @override
  String get endSoundPreviewError => 'Unable to play sound.';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get customDurationTitle => 'Custom duration';

  @override
  String get customMinutesLabel => 'Minutes';

  @override
  String get customSecondsLabel => 'Seconds';

  @override
  String customMinutesSliderLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String customSecondsSliderLabel(int seconds) {
    return '$seconds s';
  }

  @override
  String get customMinutesSuffix => 'min';

  @override
  String get customSecondsSuffix => 's';

  @override
  String customMinutesValidator(int max) {
    return 'Enter 0-$max';
  }

  @override
  String get customSecondsValidator => 'Enter 0-59';

  @override
  String get customDurationZeroError => 'Total duration must be greater than 0';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get timerDisplayPrestart => 'Get ready';

  @override
  String get timerDisplayRunning => 'Tap to pause / long press to reset';

  @override
  String get timerDisplayCompleted => 'Tap to start / long press to reset';

  @override
  String get timerDisplayIdle => 'Tap to start / long press to reset';

  @override
  String get timerDisplayOverlayCompleted => 'Finished';
}
