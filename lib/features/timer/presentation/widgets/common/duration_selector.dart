import 'package:flutter/material.dart';

import '../../../../../core/settings/app_language.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../utils/duration_formatter.dart';
import 'timer_component_layout.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({
    super.key,
    required this.language,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onCustom,
    required this.isInteractionDisabled,
  });

  final AppLanguage language;
  final List<int> options;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustom;
  final bool isInteractionDisabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = options.toSet().toList()..sort((a, b) => b.compareTo(a));
    return Wrap(
      spacing: TimerComponentLayout.chipSpacing,
      runSpacing: TimerComponentLayout.chipRunSpacing,
      alignment: WrapAlignment.center,
      children: [
        for (final seconds in sorted)
          ChoiceChip(
            label: Text(optionLabelFor(language, seconds)),
            selected: selected == seconds,
            onSelected: isInteractionDisabled ? null : (_) => onSelect(seconds),
          ),
        ActionChip(
          label: Text(l10n.customDurationAction),
          onPressed: isInteractionDisabled ? null : onCustom,
        ),
      ],
    );
  }
}
