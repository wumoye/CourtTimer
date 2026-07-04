import 'dart:async';

import 'package:courttimer/core/settings/settings_storage.dart';
import 'package:courttimer/features/timer/controller/timer_controller.dart';
import 'package:courttimer/features/timer/services/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('final countdown does not queue behind slow TTS', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = SettingsStorage(prefs);
    final speech = _SlowCountdownSpeechService();
    final controller = TimerController(
      speechService: speech,
      storage: storage,
      enableWake: () async {},
      disableWake: () async {},
    );
    addTearDown(controller.dispose);

    await controller.init();
    controller.applyCustomDuration(11);
    await controller.toggleStartPause();

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(speech.countdownNumbers, [10]);

    await Future<void>.delayed(const Duration(seconds: 1));
    expect(speech.countdownNumbers, [10, 9]);
  });

  test('resume waits for the previous speech stop to finish', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = SettingsStorage(prefs);
    final speech = _SlowCountdownSpeechService();
    final controller = TimerController(
      speechService: speech,
      storage: storage,
      enableWake: () async {},
      disableWake: () async {},
    );
    addTearDown(controller.dispose);

    await controller.init();
    controller.applyCustomDuration(11);
    await controller.toggleStartPause();

    speech.delayNextStop();
    controller.pause();
    final resume = controller.toggleStartPause();
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isRunning, isFalse);

    speech.completeStop();
    await resume;
    expect(controller.state.isRunning, isTrue);
  });
}

class _SlowCountdownSpeechService implements TimerSpeechService {
  final List<int> countdownNumbers = <int>[];
  bool _countdownStarted = false;
  Completer<void>? _pendingStop;

  void delayNextStop() {
    _pendingStop = Completer<void>();
  }

  void completeStop() {
    _pendingStop?.complete();
    _pendingStop = null;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> speakStart() async {
    _countdownStarted = true;
  }

  @override
  Future<void> speakNumber(int number) {
    if (!_countdownStarted) {
      return Future<void>.value();
    }
    countdownNumbers.add(number);
    return Completer<void>().future;
  }

  @override
  Future<void> speakRemaining(int seconds) async {}

  @override
  Future<void> speakTimeUp() async {}

  @override
  Future<void> stop() => _pendingStop?.future ?? Future<void>.value();

  @override
  void dispose() {}
}
