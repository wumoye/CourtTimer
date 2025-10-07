import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';
import 'speech_mode.dart';

class SettingsStorage {
  SettingsStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLanguage = 'settings.language';
  static const _keySpeechMode = 'settings.speechMode';
  static const _keyEndSound = 'settings.endSound';

  static const _keyTimerSelectedSeconds = 'timer.selectedSeconds';
  static const _keyTimerCustomSeconds = 'timer.customSeconds';
  static const _keyTimerEnabledMilestones = 'timer.enabledMilestones';
  static const _keyTimerFinalCountdown = 'timer.finalCountdown';

  AppLanguage loadLanguage() {
    final index = _prefs.getInt(_keyLanguage);
    if (index == null || index < 0 || index >= AppLanguage.values.length) {
      return AppLanguage.zh;
    }
    return AppLanguage.values[index];
  }

  void saveLanguage(AppLanguage value) {
    _prefs.setInt(_keyLanguage, value.index);
  }

  SpeechMode loadSpeechMode() {
    final index = _prefs.getInt(_keySpeechMode);
    if (index == null || index < 0 || index >= SpeechMode.values.length) {
      return SpeechMode.systemTts;
    }
    return SpeechMode.values[index];
  }

  void saveSpeechMode(SpeechMode value) {
    _prefs.setInt(_keySpeechMode, value.index);
  }

  String? loadEndSound() {
    final path = _prefs.getString(_keyEndSound);
    if (path == null || path.isEmpty) {
      return null;
    }
    return path;
  }

  void saveEndSound(String? path) {
    if (path == null || path.isEmpty) {
      _prefs.remove(_keyEndSound);
      return;
    }
    _prefs.setString(_keyEndSound, path);
  }

  int? loadTimerSelectedSeconds() => _prefs.getInt(_keyTimerSelectedSeconds);

  void saveTimerSelectedSeconds(int seconds) {
    _prefs.setInt(_keyTimerSelectedSeconds, seconds);
  }

  int? loadTimerCustomSeconds() => _prefs.getInt(_keyTimerCustomSeconds);

  void saveTimerCustomSeconds(int? seconds) {
    if (seconds == null) {
      _prefs.remove(_keyTimerCustomSeconds);
      return;
    }
    _prefs.setInt(_keyTimerCustomSeconds, seconds);
  }

  Set<int>? loadTimerEnabledMilestones() {
    final list = _prefs.getStringList(_keyTimerEnabledMilestones);
    if (list == null) {
      return null;
    }
    return list.map(int.parse).toSet();
  }

  void saveTimerEnabledMilestones(Set<int> values) {
    final list = values.map((e) => e.toString()).toList();
    _prefs.setStringList(_keyTimerEnabledMilestones, list);
  }

  bool loadTimerFinalCountdown() =>
      _prefs.getBool(_keyTimerFinalCountdown) ?? true;

  void saveTimerFinalCountdown(bool value) {
    _prefs.setBool(_keyTimerFinalCountdown, value);
  }
}
