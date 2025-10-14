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
  // 将最后10秒的数字播报串行化，避免相邻数字互相打断造成不流畅
  Future<void> _finalSpeakQueue = Future.value();

  Future<void> init() async {
    await _speech.init();
    // 清理历史预设：仅保留 6 分钟作为预设；如果历史选中为 1 分钟/30 秒/15 秒等，重置为 6 分钟。
    _sanitizeSelection();
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
    // 清空最后十秒的串行播报队列，避免残留数字在重置后串播
    _finalSpeakQueue = Future.value();
    final target = seconds ?? _state.selectedSeconds;
    final options = _rebuildDurationOptions(target);
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

  /// 重置到选中时长，并直接开始下一把（包含预备3-2-1）
  Future<void> startNextRound() async {
    reset();
    await toggleStartPause();
  }

  void selectDuration(int seconds) {
    if (_state.isRunning || _state.isPrestart) {
      return;
    }
    final options = _rebuildDurationOptions(seconds);
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
        _finalSpeakQueue = _finalSpeakQueue.then((_) => _speech.speakNumber(next));
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

  List<int> _rebuildDurationOptions(int selected) {
    // 仅保留预设（6分钟）以及当前选中的时长。
    final options = defaultDurations.toSet();
    options.add(selected);
    final sorted = options.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  void _sanitizeSelection() {
    final allowed = defaultDurations.toSet();
    final current = _state.selectedSeconds;
    if (!allowed.contains(current)) {
      final target = defaultDurations.first;
      final options = _rebuildDurationOptions(target);
      _setState(
        _state.copyWith(
          selectedSeconds: target,
          remainingSeconds: target,
          durationOptions: options,
        ),
      );
      _storage.saveTimerSelectedSeconds(target);
      return;
    }
    // 即便已在允许集合内，仍按新规则重建选项，确保不会遗留旧的 1m/30s/15s 选项
    final options = _rebuildDurationOptions(current);
    if (!listEquals(options, _state.durationOptions)) {
      _setState(_state.copyWith(durationOptions: options));
    }
  }

  void _setState(TimerState newState) {
    if (_disposed) {
      return;
    }
    _state = newState;
    notifyListeners();
  }
}
