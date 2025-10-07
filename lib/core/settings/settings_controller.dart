import 'package:flutter/foundation.dart';

import 'app_language.dart';
import 'settings_storage.dart';
import 'speech_mode.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storage)
    : _language = AppLanguage.zh,
      _speechMode = SpeechMode.systemTts,
      _endSoundAsset = null;

  final SettingsStorage _storage;

  AppLanguage _language;
  SpeechMode _speechMode;
  String? _endSoundAsset;

  SettingsStorage get storage => _storage;
  AppLanguage get language => _language;
  SpeechMode get speechMode => _speechMode;
  String? get endSoundAsset => _endSoundAsset;

  Future<void> init() async {
    _language = _storage.loadLanguage();
    _speechMode = _storage.loadSpeechMode();
    _endSoundAsset = _storage.loadEndSound();
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
}
