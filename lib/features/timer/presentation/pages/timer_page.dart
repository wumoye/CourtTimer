import 'package:flutter/material.dart';

import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/speech_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../controller/timer_controller.dart';
import '../../model/timer_state.dart';
import '../widgets/common/announcement_panel.dart';
import '../widgets/dialogs/custom_duration_dialog.dart';
import '../widgets/common/duration_selector.dart';
import '../widgets/display/timer_display.dart';
import '../widgets/settings/timer_settings_sheet.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late TimerController _controller;
  bool _controllerReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllerReady) {
      final speechService = SpeechScope.of(context);
      final settingsController = SettingsScope.of(context);
      _controller = TimerController(
        speechService: speechService,
        storage: settingsController.storage,
      );
      _controller.init();
      _controllerReady = true;
    }
  }

  @override
  void dispose() {
    if (_controllerReady) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controllerReady) {
      return const SizedBox.shrink();
    }

    final settings = SettingsScope.of(context);
    final language = settings.language;
    final l10n = AppLocalizations.of(context)!;

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
                  _Header(
                    title: l10n.timerPageTitle,
                    onOpenSettings: _openSettings,
                  ),
                  const SizedBox(height: 24),
                  DurationSelector(
                    language: language,
                    options: state.durationOptions,
                    selected: state.selectedSeconds,
                    onSelect: _controller.selectDuration,
                    onCustom: () => _handleCustomDuration(state),
                    isInteractionDisabled: state.isRunning || state.isPrestart,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.announcementSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  AnnouncementPanel(
                    language: language,
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
                    label: Text(l10n.resetButtonLabel),
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

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => const TimerSettingsSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onOpenSettings});

  final String title;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(title, style: textStyle, textAlign: TextAlign.center),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onOpenSettings,
            tooltip: AppLocalizations.of(context)!.settingsTitle,
          ),
        ),
      ],
    );
  }
}
