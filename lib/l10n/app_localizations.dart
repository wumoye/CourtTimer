import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Court Timer'**
  String get appTitle;

  /// No description provided for @timerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get timerPageTitle;

  /// No description provided for @announcementSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementSectionTitle;

  /// No description provided for @resetButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButtonLabel;

  /// No description provided for @customDurationAction.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDurationAction;

  /// No description provided for @finalCountdownLabel.
  ///
  /// In en, this message translates to:
  /// **'10-0 final countdown'**
  String get finalCountdownLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsSpeechModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Speech mode'**
  String get settingsSpeechModeLabel;

  /// No description provided for @settingsEndSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'End sound'**
  String get settingsEndSoundLabel;
  

  /// No description provided for @speechModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Device TTS (offline)'**
  String get speechModeSystem;

  /// No description provided for @speechModeOffline.
  ///
  /// In en, this message translates to:
  /// **'Audio pack (offline, coming soon)'**
  String get speechModeOffline;

  /// No description provided for @speechModeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online TTS (coming soon)'**
  String get speechModeOnline;

  /// No description provided for @speechModeUnavailableNote.
  ///
  /// In en, this message translates to:
  /// **'Other speech modes will be available in a future update.'**
  String get speechModeUnavailableNote;

  /// No description provided for @settingsSpeechModeHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose how announcements are spoken.'**
  String get settingsSpeechModeHelp;

  /// No description provided for @settingsEndSoundHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the whistle or alert to play when time expires.'**
  String get settingsEndSoundHelp;

  /// No description provided for @endSoundNoneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get endSoundNoneOption;

  /// No description provided for @endSoundPreviewPlay.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get endSoundPreviewPlay;

  /// No description provided for @endSoundPreviewStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get endSoundPreviewStop;

  /// No description provided for @endSoundPreviewError.
  ///
  /// In en, this message translates to:
  /// **'Unable to play sound.'**
  String get endSoundPreviewError;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @customDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom duration'**
  String get customDurationTitle;

  /// No description provided for @customMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get customMinutesLabel;

  /// No description provided for @customSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get customSecondsLabel;

  /// No description provided for @customMinutesSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String customMinutesSliderLabel(int minutes);

  /// No description provided for @customSecondsSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String customSecondsSliderLabel(int seconds);

  /// No description provided for @customMinutesSuffix.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get customMinutesSuffix;

  /// No description provided for @customSecondsSuffix.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get customSecondsSuffix;

  /// No description provided for @customMinutesValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter 0-{max}'**
  String customMinutesValidator(int max);

  /// No description provided for @customSecondsValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter 0-59'**
  String get customSecondsValidator;

  /// No description provided for @customDurationZeroError.
  ///
  /// In en, this message translates to:
  /// **'Total duration must be greater than 0'**
  String get customDurationZeroError;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// No description provided for @timerDisplayPrestart.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get timerDisplayPrestart;

  /// No description provided for @timerDisplayRunning.
  ///
  /// In en, this message translates to:
  /// **'Tap to pause / long press to reset'**
  String get timerDisplayRunning;

  /// No description provided for @timerDisplayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tap to start / long press to reset'**
  String get timerDisplayCompleted;

  /// No description provided for @timerDisplayIdle.
  ///
  /// In en, this message translates to:
  /// **'Tap to start / long press to reset'**
  String get timerDisplayIdle;

  /// No description provided for @timerDisplayOverlayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get timerDisplayOverlayCompleted;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
