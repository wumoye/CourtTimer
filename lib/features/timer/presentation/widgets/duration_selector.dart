import 'package:flutter/material.dart';

import '../../utils/duration_formatter.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onCustom,
    required this.isInteractionDisabled,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustom;
  final bool isInteractionDisabled;

  @override
  Widget build(BuildContext context) {
    final sorted = options.toSet().toList()..sort((a, b) => b.compareTo(a));
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final seconds in sorted)
          ChoiceChip(
            label: Text(labelForSeconds(seconds)),
            selected: selected == seconds,
            onSelected: isInteractionDisabled ? null : (_) => onSelect(seconds),
          ),
        ActionChip(
          label: const Text('自定义'),
          onPressed: isInteractionDisabled ? null : onCustom,
        ),
      ],
    );
  }
}
