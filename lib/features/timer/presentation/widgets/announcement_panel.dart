import 'package:flutter/material.dart';

import '../../model/milestones.dart';

class AnnouncementPanel extends StatelessWidget {
  const AnnouncementPanel({
    super.key,
    required this.enabledMilestones,
    required this.enableFinalCountdown,
    required this.onMilestoneChanged,
    required this.onFinalCountdownChanged,
    required this.isInteractionDisabled,
  });

  final Set<int> enabledMilestones;
  final bool enableFinalCountdown;
  final void Function(int seconds, bool enabled) onMilestoneChanged;
  final ValueChanged<bool> onFinalCountdownChanged;
  final bool isInteractionDisabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final entry in milestoneLabels.entries)
          FilterChip(
            label: Text(entry.value),
            selected: enabledMilestones.contains(entry.key),
            onSelected:
                isInteractionDisabled
                    ? null
                    : (selected) => onMilestoneChanged(entry.key, selected),
          ),
        FilterChip(
          label: const Text('10~0 秒倒数'),
          selected: enableFinalCountdown,
          onSelected: isInteractionDisabled ? null : onFinalCountdownChanged,
        ),
      ],
    );
  }
}
