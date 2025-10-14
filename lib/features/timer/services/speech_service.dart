import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/settings/app_language.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/settings/speech_mode.dart';
import '../utils/duration_formatter.dart';

class SpeechService {
  SpeechService({required SettingsController settings}) : _settings = settings {
    _settings.addListener(_handleSettingsChanged);
    _audioPlayer
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency);
  }

  final SettingsController _settings;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _initialized = false;

  AppLanguage get _language => _settings.language;
  SpeechMode get _mode => _settings.speechMode;

  void _handleSettingsChanged() {
    if (_initialized && _mode == SpeechMode.systemTts) {
      _applyTtsConfiguration();
    }
  }

  Future<void> init() async {
    if (_mode != SpeechMode.systemTts) {
      // TODO: 支持其他语音模式（离线音频 / 在线服务）
      return;
    }
    if (_initialized) {
      return;
    }
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
    await _applyTtsConfiguration();
  }

  Future<void> speakStart() async {
    await _speak(_startPrompt());
  }

  Future<void> speakTimeUp() async {
    await _speak(_timeUpPrompt());
    await _playEndSound();
  }

  Future<void> speakNumber(int number) async {
    await _speak(speechNumberFor(_language, number));
  }

  Future<void> speakRemaining(int seconds) async {
    final remainingLabel = speechLabelFor(_language, seconds);
    if (remainingLabel.isEmpty) {
      return;
    }
    await _speak('${_remainingPrefix()}$remainingLabel${_sentenceEnding()}');
  }

  Future<void> stop() async {
    if (_mode == SpeechMode.systemTts) {
      await _tts.stop();
    }
    await _audioPlayer.stop();
  }

  void dispose() {
    _settings.removeListener(_handleSettingsChanged);
    _tts.stop();
    _audioPlayer.dispose();
  }

  Future<void> _applyTtsConfiguration() async {
    if (_mode != SpeechMode.systemTts) {
      return;
    }
    await _tts.setLanguage(_language.ttsLocaleTag);
    await _tts.setSpeechRate(_settings.speechRate);
    await _tts.setPitch(_pitchFor(_language));
    await _tts.setVolume(0.9);
  }

  // 保留音高按语言微调；语速改由 Settings 控制

  double _pitchFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.zh:
        return 1.05;
      case AppLanguage.en:
        return 1.0;
      case AppLanguage.ja:
        return 1.0;
    }
  }

  String _startPrompt() {
    switch (_language) {
      case AppLanguage.zh:
        return '计时开始。';
      case AppLanguage.en:
        return 'Started.';
      case AppLanguage.ja:
        return '試合開始。';
    }
  }

  String _timeUpPrompt() {
    switch (_language) {
      case AppLanguage.zh:
        return '时间到。';
      case AppLanguage.en:
        return "Time's up.";
      case AppLanguage.ja:
        return '試合終了。';
    }
  }

  String _remainingPrefix() {
    switch (_language) {
      case AppLanguage.zh:
        return '剩余';
      case AppLanguage.en:
        return 'Remaining ';
      case AppLanguage.ja:
        return '残り';
    }
  }

  String _sentenceEnding() {
    switch (_language) {
      case AppLanguage.zh:
      case AppLanguage.ja:
        return '。';
      case AppLanguage.en:
        return '.';
    }
  }

  Future<void> _speak(String text) async {
    await init();
    if (_mode != SpeechMode.systemTts) {
      return;
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _playEndSound() async {
    final asset = _settings.endSoundAsset;
    if (asset == null || asset.isEmpty) {
      await SystemSound.play(SystemSoundType.alert);
      return;
    }

    final relative =
        asset.startsWith('assets/') ? asset.substring('assets/'.length) : asset;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(relative));
      try {
        await _audioPlayer.onPlayerComplete.first.timeout(
          const Duration(seconds: 10),
        );
      } catch (_) {
        // 忽略超时，继续播报语音。
      }
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }
}
