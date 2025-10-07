import 'package:flutter/material.dart';

import '../../../../../core/settings/app_language.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../model/milestones.dart';
import '../../../utils/duration_formatter.dart';
import 'timer_component_layout.dart';

class AnnouncementPanel extends StatelessWidget {
  const AnnouncementPanel({
    super.key,
    required this.language,
    required this.enabledMilestones,
    required this.enableFinalCountdown,
    required this.onMilestoneChanged,
    required this.onFinalCountdownChanged,
    required this.isInteractionDisabled,
  });

  final AppLanguage language;
  final Set<int> enabledMilestones;
  final bool enableFinalCountdown;
  final void Function(int seconds, bool enabled) onMilestoneChanged;
  final ValueChanged<bool> onFinalCountdownChanged;
  final bool isInteractionDisabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: TimerComponentLayout.chipSpacing,
      runSpacing: TimerComponentLayout.chipRunSpacing,
      alignment: WrapAlignment.center,
      children: [
        for (final seconds in milestoneSeconds)
          FilterChip(
            label: Text(milestoneLabelFor(language, seconds)),
            selected: enabledMilestones.contains(seconds),
            onSelected:
                isInteractionDisabled
                    ? null
                    : (selected) => onMilestoneChanged(seconds, selected),
          ),
        FilterChip(
          label: Text(l10n.finalCountdownLabel),
          selected: enableFinalCountdown,
          onSelected: isInteractionDisabled ? null : onFinalCountdownChanged,
        ),
      ],
    );
  }
}
