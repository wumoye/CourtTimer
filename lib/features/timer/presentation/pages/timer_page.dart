import 'package:flutter/material.dart';

import '../../controller/timer_controller.dart';
import '../../model/timer_state.dart';
import '../widgets/announcement_panel.dart';
import '../widgets/custom_duration_dialog.dart';
import '../widgets/duration_selector.dart';
import '../widgets/timer_display.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late final TimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimerController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '篮球倒计时',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DurationSelector(
                    options: state.durationOptions,
                    selected: state.selectedSeconds,
                    onSelect: _controller.selectDuration,
                    onCustom: () => _handleCustomDuration(state),
                    isInteractionDisabled: state.isRunning || state.isPrestart,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '语音提醒',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  AnnouncementPanel(
                    enabledMilestones: state.enabledMilestones,
                    enableFinalCountdown: state.enableFinalCountdown,
                    onMilestoneChanged:
                        (seconds, enabled) =>
                            _controller.toggleMilestone(seconds, enabled),
                    onFinalCountdownChanged: _controller.toggleFinalCountdown,
                    isInteractionDisabled: state.isRunning || state.isPrestart,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: TimerDisplay(
                        state: state,
                        onToggle: () => _controller.toggleStartPause(),
                        onReset: () => _controller.reset(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _controller.reset(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重置计时'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCustomDuration(TimerState state) async {
    final result = await showCustomDurationDialog(
      context: context,
      initialSeconds: state.selectedSeconds,
    );
    if (result != null) {
      _controller.applyCustomDuration(result);
    }
  }
}
