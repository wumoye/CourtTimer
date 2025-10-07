import 'milestones.dart';

class TimerState {
  const TimerState({
    required this.selectedSeconds,
    required this.remainingSeconds,
    required this.durationOptions,
    required this.enabledMilestones,
    required this.enableFinalCountdown,
    required this.isRunning,
    required this.isPrestart,
    this.prestartCount,
    this.customSeconds,
  });

  final int selectedSeconds;
  final int remainingSeconds;
  final List<int> durationOptions;
  final Set<int> enabledMilestones;
  final bool enableFinalCountdown;
  final bool isRunning;
  final bool isPrestart;
  final int? prestartCount;
  final int? customSeconds;

  bool get isCompleted => !isRunning && !isPrestart && remainingSeconds <= 0;

  TimerState copyWith({
    int? selectedSeconds,
    int? remainingSeconds,
    List<int>? durationOptions,
    Set<int>? enabledMilestones,
    bool? enableFinalCountdown,
    bool? isRunning,
    bool? isPrestart,
    int? prestartCount,
    int? customSeconds,
  }) {
    return TimerState(
      selectedSeconds: selectedSeconds ?? this.selectedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      durationOptions: durationOptions ?? this.durationOptions,
      enabledMilestones: enabledMilestones ?? this.enabledMilestones,
      enableFinalCountdown: enableFinalCountdown ?? this.enableFinalCountdown,
      isRunning: isRunning ?? this.isRunning,
      isPrestart: isPrestart ?? this.isPrestart,
      prestartCount: prestartCount,
      customSeconds: customSeconds ?? this.customSeconds,
    );
  }

  static TimerState initial() {
    return TimerState(
      selectedSeconds: defaultDurations.first,
      remainingSeconds: defaultDurations.first,
      durationOptions: List<int>.from(defaultDurations),
      enabledMilestones: milestoneLabels.keys.toSet(),
      enableFinalCountdown: true,
      isRunning: false,
      isPrestart: false,
      prestartCount: null,
      customSeconds: null,
    );
  }
}
