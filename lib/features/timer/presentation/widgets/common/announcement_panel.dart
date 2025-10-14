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
    required this.onAddMilestone,
  });

  final AppLanguage language;
  final Set<int> enabledMilestones;
  final bool enableFinalCountdown;
  final void Function(int seconds, bool enabled) onMilestoneChanged;
  final ValueChanged<bool> onFinalCountdownChanged;
  final bool isInteractionDisabled;
  final VoidCallback onAddMilestone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 合并默认节点与已启用的自定义节点，统一渲染为可切换的 Chip。
    final allMilestones = <int>{...milestoneSeconds, ...enabledMilestones}
        .toList()
      ..sort((a, b) => b.compareTo(a));

    return Wrap(
      spacing: TimerComponentLayout.chipSpacing,
      runSpacing: TimerComponentLayout.chipRunSpacing,
      alignment: WrapAlignment.center,
      children: [
        for (final seconds in allMilestones)
          FilterChip(
            label: Text(milestoneLabelFor(language, seconds)),
            selected: enabledMilestones.contains(seconds),
            onSelected:
                isInteractionDisabled
                    ? null
                    : (selected) => onMilestoneChanged(seconds, selected),
          ),
        // 添加自定义报时（使用现有自定义时长对话框，无需新增文案）
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: AppLocalizations.of(context)!.customDurationTitle,
          onPressed: isInteractionDisabled ? null : onAddMilestone,
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
