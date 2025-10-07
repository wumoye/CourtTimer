import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/settings/settings_storage.dart';
import '../model/milestones.dart';
import '../model/timer_state.dart';
import '../services/speech_service.dart';
import '../services/wake_service.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    required SpeechService speechService,
    required SettingsStorage storage,
  })  : _speech = speechService,
        _storage = storage,
        _state = TimerState.initial(
          selectedSeconds: storage.loadTimerSelectedSeconds(),
          customSeconds: storage.loadTimerCustomSeconds(),
          enabledMilestones: storage.loadTimerEnabledMilestones(),
          enableFinalCountdown: storage.loadTimerFinalCountdown(),
        );

  TimerState _state;
  TimerState get state => _state;

  final SpeechService _speech;
  final SettingsStorage _storage;
  Timer? _ticker;
  final Set<int> _announcedMilestones = <int>{};
  bool _disposed = false;
  bool _hasStartedOnce = false;

  Future<void> init() async {
    await _speech.init();
  }

  Future<void> toggleStartPause() async {
    if (_state.isRunning) {
      pause();
      return;
    }
    if (_state.isPrestart) {
      _cancelPrestart();
      return;
    }
    await _prepareAndStart();
  }

  void pause() {
    _ticker?.cancel();
    unawaited(ScreenWakeService.disable());
    unawaited(_speech.stop());
    _setState(
      _state.copyWith(isRunning: false, isPrestart: false, prestartCount: null),
    );
  }

  void reset({int? seconds}) {
    _ticker?.cancel();
    unawaited(ScreenWakeService.disable());
    unawaited(_speech.stop());
    final target = seconds ?? _state.selectedSeconds;
    final options = _rebuildDurationOptions(
      target,
      customSeconds: seconds ?? _state.customSeconds,
    );
    _setState(
      _state.copyWith(
        selectedSeconds: target,
        remainingSeconds: target,
        durationOptions: options,
        isRunning: false,
        isPrestart: false,
        prestartCount: null,
        customSeconds: seconds ?? _state.customSeconds,
      ),
    );
    _announcedMilestones.clear();
    _hasStartedOnce = false;
    _storage.saveTimerSelectedSeconds(target);
    if (seconds != null) {
      _storage.saveTimerCustomSeconds(seconds);
    }
  }

  void selectDuration(int seconds) {
    if (_state.isRunning || _state.isPrestart) {
      return;
    }
    final options = _rebuildDurationOptions(
      seconds,
      customSeconds: _state.customSeconds,
    );
    _setState(
      _state.copyWith(
        selectedSeconds: seconds,
        remainingSeconds: seconds,
        durationOptions: options,
      ),
    );
    _announcedMilestones.clear();
    _hasStartedOnce = false;
    _storage.saveTimerSelectedSeconds(seconds);
  }

  void applyCustomDuration(int seconds) {
    if (seconds <= 0) {
      return;
    }
    _storage.saveTimerCustomSeconds(seconds);
    reset(seconds: seconds);
  }

  void toggleMilestone(int seconds, bool enabled) {
    final updated = Set<int>.from(_state.enabledMilestones);
    if (enabled) {
      updated.add(seconds);
    } else {
      updated.remove(seconds);
    }
    _setState(_state.copyWith(enabledMilestones: updated));
    _storage.saveTimerEnabledMilestones(updated);
  }

  void toggleFinalCountdown(bool value) {
    _setState(_state.copyWith(enableFinalCountdown: value));
    _storage.saveTimerFinalCountdown(value);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(ScreenWakeService.disable());
    _speech.dispose();
    _disposed = true;
    super.dispose();
  }

  Future<void> _prepareAndStart() async {
    if (_state.remainingSeconds <= 0) {
      _setState(_state.copyWith(remainingSeconds: _state.selectedSeconds));
      _hasStartedOnce = false;
    }

    final isResume = _hasStartedOnce && _state.remainingSeconds > 0;

    if (isResume) {
      await ScreenWakeService.enable();
      _setState(
        _state.copyWith(isRunning: true, isPrestart: false, prestartCount: null),
      );
      _startTicker();
      return;
    }

    _announcedMilestones.clear();
    _setState(_state.copyWith(isPrestart: true, prestartCount: 3));

    for (final number in [3, 2, 1]) {
      if (!_state.isPrestart) {
        return;
      }
      _setState(_state.copyWith(prestartCount: number));
      await _speech.speakNumber(number);
      if (!_state.isPrestart) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (!_state.isPrestart) {
      return;
    }

    await _speech.speakStart();
    if (!_state.isPrestart) {
      return;
    }

    await ScreenWakeService.enable();
    _setState(
      _state.copyWith(isPrestart: false, isRunning: true, prestartCount: null),
    );
    _hasStartedOnce = true;
    _startTicker();
  }

  void _cancelPrestart() {
    unawaited(_speech.stop());
    _setState(_state.copyWith(isPrestart: false, prestartCount: null));
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = _state.remainingSeconds;
      final next = current - 1;

      if (_shouldAnnounceMilestone(next)) {
        unawaited(_speech.speakRemaining(next));
      }

      if (_state.enableFinalCountdown && next > 0 && next <= 10) {
        unawaited(_speech.speakNumber(next));
      }

      if (next <= 0) {
        unawaited(_speech.speakTimeUp());
        timer.cancel();
        unawaited(ScreenWakeService.disable());
        _setState(
          _state.copyWith(
            remainingSeconds: 0,
            isRunning: false,
            isPrestart: false,
            prestartCount: null,
          ),
        );
        _hasStartedOnce = false;
        return;
      }

      _setState(_state.copyWith(remainingSeconds: next));
    });
  }

  bool _shouldAnnounceMilestone(int seconds) {
    if (seconds <= 10) {
      return false;
    }
    if (seconds > _state.selectedSeconds) {
      return false;
    }
    if (!_state.enabledMilestones.contains(seconds)) {
      return false;
    }
    if (_announcedMilestones.contains(seconds)) {
      return false;
    }
    _announcedMilestones.add(seconds);
    return true;
  }

  List<int> _rebuildDurationOptions(int selected, {int? customSeconds}) {
    final options = defaultDurations.toSet();
    options.add(selected);
    if (customSeconds != null) {
      options.add(customSeconds);
    }
    final sorted = options.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  void _setState(TimerState newState) {
    if (_disposed) {
      return;
    }
    _state = newState;
    notifyListeners();
  }
}
