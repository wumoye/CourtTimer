import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/duration_formatter.dart';

class SpeechService {
  SpeechService();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.6);
    await _tts.setPitch(1.05);
    await _tts.setVolume(0.9);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> speakStart() async {
    await _speak('计时开始，准备进攻！');
  }

  Future<void> speakTimeUp() async {
    await SystemSound.play(SystemSoundType.alert);
    await _speak('时间到！');
  }

  Future<void> speakNumber(int number) async {
    await _speak(speechNumberFor(number));
  }

  Future<void> speakRemaining(int seconds) async {
    final remainingLabel = speechLabelFor(seconds);
    if (remainingLabel.isEmpty) {
      return;
    }
    await _speak('还剩$remainingLabel，保持节奏！');
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }

  Future<void> _speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }
}
