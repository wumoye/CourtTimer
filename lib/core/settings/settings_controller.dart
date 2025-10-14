import 'package:flutter/foundation.dart';

import 'app_language.dart';
import 'settings_storage.dart';
import 'speech_mode.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storage)
    : _language = AppLanguage.zh,
      _speechMode = SpeechMode.systemTts,
      _endSoundAsset = null,
      _speechRate = 0.55;

  final SettingsStorage _storage;

  AppLanguage _language;
  SpeechMode _speechMode;
  String? _endSoundAsset;
  double _speechRate;

  SettingsStorage get storage => _storage;
  AppLanguage get language => _language;
  SpeechMode get speechMode => _speechMode;
  String? get endSoundAsset => _endSoundAsset;
  double get speechRate => _speechRate;

  Future<void> init() async {
    _language = _storage.loadLanguage();
    _speechMode = _storage.loadSpeechMode();
    _endSoundAsset = _storage.loadEndSound();
    final loadedRate = _storage.loadSpeechRate();
    final effective = loadedRate ?? _defaultSpeechRateFor(_language);
    _speechRate = (effective.clamp(0.3, 1.0) as num).toDouble();
    notifyListeners();
  }

  void updateLanguage(AppLanguage language) {
    if (language == _language) {
      return;
    }
    _language = language;
    _storage.saveLanguage(language);
    notifyListeners();
  }

  void updateSpeechMode(SpeechMode mode) {
    if (mode == _speechMode) {
      return;
    }
    _speechMode = mode;
    _storage.saveSpeechMode(mode);
    notifyListeners();
  }

  void updateEndSoundAsset(String? assetPath) {
    if (assetPath == _endSoundAsset) {
      return;
    }
    _endSoundAsset = assetPath;
    _storage.saveEndSound(assetPath);
    notifyListeners();
  }

  void updateSpeechRate(double rate) {
    final clamped = (rate.clamp(0.3, 1.0) as num).toDouble();
    if (clamped == _speechRate) {
      return;
    }
    _speechRate = clamped;
    _storage.saveSpeechRate(_speechRate);
    notifyListeners();
  }

  double _defaultSpeechRateFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.zh:
        return 0.55;
      case AppLanguage.en:
        return 0.50;
      case AppLanguage.ja:
        return 0.55;
    }
  }
}
