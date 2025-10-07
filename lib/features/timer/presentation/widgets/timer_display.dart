import 'package:flutter/material.dart';

import '../../../../core/settings/app_language.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/timer_state.dart';
import '../../utils/duration_formatter.dart';

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
    final color = Colors.blueGrey.shade900;
    final isPrestart = state.isPrestart && state.prestartCount != null;
    final displayText =
        isPrestart
            ? state.prestartCount!.toString()
            : formatAsDigits(state.remainingSeconds);
    final l10n = AppLocalizations.of(context)!;
    final caption = _buildCaption(l10n, language);
    final showCompletedOverlay = state.isCompleted;

    final textTheme = Theme.of(context).textTheme;
    final headlineStyle =
        textTheme.headlineLarge?.copyWith(
          letterSpacing: 4,
          color: Colors.white,
        ) ??
        const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: Colors.white,
        );
    final captionStyle =
        textTheme.titleMedium?.copyWith(color: Colors.white70) ??
        const TextStyle(color: Colors.white70);

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onReset,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
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
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            l10n.timerDisplayOverlayCompleted,
                            style: headlineStyle.copyWith(
                              fontSize: 48,
                              letterSpacing: 8,
                            ),
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
