import 'package:flutter/material.dart';

import '../../../../../core/settings/app_language.dart';
import '../../../../../core/settings/settings_scope.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../model/timer_state.dart';
import '../../../utils/duration_formatter.dart';
import 'timer_display_theme.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.state,
    required this.onToggle,
    required this.onReset,
  });

  final TimerState state;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final language = settings.language;
    final isPrestart = state.isPrestart && state.prestartCount != null;
    final displayText =
        isPrestart
            ? state.prestartCount!.toString()
            : formatAsDigits(state.remainingSeconds);
    final l10n = AppLocalizations.of(context)!;
    final caption = _buildCaption(l10n, language);
    final showCompletedOverlay = state.isCompleted;

    final textTheme = Theme.of(context).textTheme;
    final headlineStyle = TimerDisplayTheme.headline(textTheme);
    final overlayStyle = TimerDisplayTheme.overlay(headlineStyle);
    final captionStyle = TimerDisplayTheme.caption(textTheme);

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onReset,
      child: Container(
        width: double.infinity,
        padding: TimerDisplayTheme.padding,
        decoration: TimerDisplayTheme.containerDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(displayText, style: headlineStyle),
                  if (showCompletedOverlay)
                    Positioned.fill(
                      child: Container(
                        decoration: TimerDisplayTheme.overlayDecoration(),
                        child: Center(
                          child: Text(
                            l10n.timerDisplayOverlayCompleted,
                            style: overlayStyle,
                          ),
                        ),
                      ),
                    ),
              ],
              ),
            ),
            const SizedBox(height: 16),
            Text(caption, style: captionStyle),
          ],
        ),
      ),
    );
  }

  String _buildCaption(AppLocalizations l10n, AppLanguage language) {
    if (state.isPrestart && state.prestartCount != null) {
      return l10n.timerDisplayPrestart;
    }
    if (state.isRunning) {
      return l10n.timerDisplayRunning;
    }
    if (state.isCompleted) {
      return l10n.timerDisplayCompleted;
    }
    return l10n.timerDisplayIdle;
  }
}
