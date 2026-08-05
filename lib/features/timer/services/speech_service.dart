import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/settings/app_language.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/settings/speech_mode.dart';
import '../utils/duration_formatter.dart';

abstract interface class TimerSpeechService {
  Future<void> init();
  Future<void> speakStart();
  Future<void> speakTimeUp();
  Future<void> speakNumber(int number);
  Future<void> speakRemaining(int seconds);
  Future<void> stop();
  void dispose();
}

class SpeechService implements TimerSpeechService {
  SpeechService({required SettingsController settings}) : _settings = settings {
    _settings.addListener(_handleSettingsChanged);
    _audioPlayer
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency);
    _feedbackPlayer
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency);
  }

  final SettingsController _settings;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();
  bool _initialized = false;
  bool _audioContextConfigured = false;

  AppLanguage get _language => _settings.language;
  SpeechMode get _mode => _settings.speechMode;

  void _handleSettingsChanged() {
    if (_initialized && _mode == SpeechMode.systemTts) {
      _applyTtsConfiguration();
    }
  }

  @override
  Future<void> init() async {
    await _configurePlaybackAudioContext();
    if (_mode != SpeechMode.systemTts) {
      // TODO: 支持其他语音模式（离线音频 / 在线服务）
      return;
    }
    if (_initialized) {
      return;
    }
    await _tts.awaitSpeakCompletion(true);
    // On Android this marks speech as a navigation-style prompt, rather than
    // media playback. Together with `focus: true` in _speak this requests a
    // short-lived focus that lets the music app duck and resume automatically.
    try {
      await _tts.setAudioAttributesForNavigation();
    } catch (_) {
      // This Android-specific hint is optional on the other platforms.
    }
    _initialized = true;
    await _applyTtsConfiguration();
  }

  @override
  Future<void> speakStart() async {
    await _speak(_startPrompt());
  }

  @override
  Future<void> speakTimeUp() async {
    await _speak(_timeUpPrompt());
    await _playEndSound();
  }

  @override
  Future<void> speakNumber(int number) async {
    await _speak(speechNumberFor(_language, number));
  }

  @override
  Future<void> speakRemaining(int seconds) async {
    final remainingLabel = speechLabelFor(_language, seconds);
    if (remainingLabel.isEmpty) {
      return;
    }
    await _speak('${_remainingPrefix()}$remainingLabel${_sentenceEnding()}');
  }

  @override
  Future<void> stop() async {
    if (_mode == SpeechMode.systemTts) {
      await _tts.stop();
    }
    await _audioPlayer.stop();
  }

  /// Plays the user-selected sound for pause and resume feedback.
  Future<void> playFeedback() async {
    final asset = _settings.feedbackSoundAsset;
    if (asset == null || asset.isEmpty) {
      await SystemSound.play(SystemSoundType.alert);
      return;
    }

    final relative =
        asset.startsWith('assets/') ? asset.substring('assets/'.length) : asset;
    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource(relative));
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  void dispose() {
    _settings.removeListener(_handleSettingsChanged);
    _tts.stop();
    _audioPlayer.dispose();
    _feedbackPlayer.dispose();
  }

  Future<void> _applyTtsConfiguration() async {
    if (_mode != SpeechMode.systemTts) {
      return;
    }
    await _tts.setLanguage(_language.ttsLocaleTag);
    await _tts.setSpeechRate(_settings.speechRate);
    await _tts.setPitch(_pitchFor(_language));
    await _tts.setVolume(1.0);
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
    try {
      await init();
      if (_mode != SpeechMode.systemTts) {
        return;
      }
      await _tts.stop();
      await _tts.speak(text, focus: true);
    } catch (_) {
      // TTS is optional feedback. A platform-engine failure must not block
      // timer state changes or surface as an unhandled asynchronous error.
    }
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

  /// Makes timer prompts transient audio instead of competing media playback.
  /// Android then uses `AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK`; iOS uses its
  /// equivalent duck-and-mix session configuration.
  Future<void> _configurePlaybackAudioContext() async {
    if (_audioContextConfigured) {
      return;
    }

    final duckingContext =
        AudioContextConfig(focus: AudioContextConfigFocus.duckOthers).build();
    try {
      await _audioPlayer.setAudioContext(duckingContext);
      await _feedbackPlayer.setAudioContext(duckingContext);
      _audioContextConfigured = true;
    } catch (_) {
      // Audio feedback remains best-effort if a platform lacks audio contexts.
    }
  }
}
