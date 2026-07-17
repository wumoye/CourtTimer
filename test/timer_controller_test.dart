import 'dart:async';

import 'package:courttimer/core/settings/settings_storage.dart';
import 'package:courttimer/features/timer/controller/timer_controller.dart';
import 'package:courttimer/features/timer/services/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSpeech implements TimerSpeechService {
  final List<int> numbers = <int>[];
  int timeUpCalls = 0;
  int stopCalls = 0;
  Completer<void>? _blockedNumber;
  int? _numberToBlock;
  Completer<void>? _pendingStop;

  void blockNumber(int number) {
    _numberToBlock = number;
    _blockedNumber = Completer<void>();
  }

  void delayNextStop() => _pendingStop = Completer<void>();

  void completeStop() {
    _pendingStop?.complete();
    _pendingStop = null;
  }

  @override
  void dispose() {}

  @override
  Future<void> init() async {}

  @override
  Future<void> speakNumber(int number) {
    numbers.add(number);
    final blocked = number == _numberToBlock ? _blockedNumber : null;
    if (blocked != null) {
      _blockedNumber = null;
      _numberToBlock = null;
    }
    return blocked?.future ?? Future<void>.value();
  }

  @override
  Future<void> speakRemaining(int seconds) async {}

  @override
  Future<void> speakStart() async {}

  @override
  Future<void> speakTimeUp() async => timeUpCalls++;

  @override
  Future<void> stop() {
    stopCalls++;
    return _pendingStop?.future ?? Future<void>.value();
  }
}

void main() {
  Future<TimerController> createController(_FakeSpeech speech) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final controller = TimerController(
      speechService: speech,
      storage: SettingsStorage(prefs),
      tickerInterval: const Duration(milliseconds: 10),
      prestartDelay: Duration.zero,
      playToggleFeedback: () async {},
      enableWake: () async {},
      disableWake: () async {},
    );
    await controller.init();
    controller.applyCustomDuration(12);
    controller.toggleFinalCountdown(true);
    return controller;
  }

  test('counts down once per tick and reaches zero', () async {
    final speech = _FakeSpeech();
    final controller = await createController(speech);
    addTearDown(controller.dispose);

    await controller.toggleStartPause();
    await Future<void>.delayed(const Duration(milliseconds: 140));

    expect(controller.state.remainingSeconds, 0);
    expect(controller.state.isRunning, isFalse);
    expect(speech.timeUpCalls, 1);
  });

  test(
    'resuming after paused final-countdown speech keeps announcements alive',
    () async {
      final speech = _FakeSpeech();
      final controller = await createController(speech);
      addTearDown(controller.dispose);

      speech.blockNumber(10);
      await controller.toggleStartPause();
      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(speech.numbers, contains(10));

      controller.pause();
      final pausedAt = controller.state.remainingSeconds;
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(controller.state.remainingSeconds, pausedAt);

      await controller.toggleStartPause();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(speech.numbers, contains(pausedAt - 1));
      expect(controller.state.isRunning, isTrue);
    },
  );

  test('resume waits for a pending TTS stop', () async {
    final speech = _FakeSpeech();
    final controller = await createController(speech);
    addTearDown(controller.dispose);

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
