import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../l10n/app_localizations.dart';

class CustomDurationLayout {
  static const double sliderSpacing = 8;
  static const double sectionSpacing = 12;
  static const double fieldSpacing = 16;
}

Future<int?> showCustomDurationDialog({
  required BuildContext context,
  required int initialSeconds,
  int maxMinutes = 20,
}) {
  final rawMinutes = initialSeconds ~/ 60;
  final rawSeconds = initialSeconds % 60;
  final initialMinutes = rawMinutes < 0
      ? 0
      : rawMinutes > maxMinutes
          ? maxMinutes
          : rawMinutes;
  final initialRemain = rawSeconds < 0
      ? 0
      : rawSeconds > 59
          ? 59
          : rawSeconds;

  return showDialog<int>(
    context: context,
    builder: (dialogContext) => _CustomDurationDialog(
      maxMinutes: maxMinutes,
      initialMinutes: initialMinutes,
      initialSeconds: initialRemain,
    ),
  );
}

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog({
    required this.maxMinutes,
    required this.initialMinutes,
    required this.initialSeconds,
  });

  final int maxMinutes;
  final int initialMinutes;
  final int initialSeconds;

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  late int _minutesValue;
  late int _secondsValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _minutesValue = widget.initialMinutes;
    _secondsValue = widget.initialSeconds;
    _minutesController = TextEditingController(
      text: _minutesValue.toString(),
    );
    _secondsController = TextEditingController(
      text: _secondsValue.toString(),
    );
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.customDurationTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DurationSliderTile(
              label: l10n.customMinutesLabel,
              value: _minutesValue,
              min: 0,
              max: widget.maxMinutes,
              divisions: widget.maxMinutes,
              descriptionBuilder: l10n.customMinutesSliderLabel,
              onChanged: _syncMinutes,
            ),
            const SizedBox(height: CustomDurationLayout.sliderSpacing),
            _DurationSliderTile(
              label: l10n.customSecondsLabel,
              value: _secondsValue,
              min: 0,
              max: 59,
              divisions: 59,
              descriptionBuilder: l10n.customSecondsSliderLabel,
              onChanged: _syncSeconds,
            ),
            const SizedBox(height: CustomDurationLayout.sectionSpacing),
            Row(
              children: [
                Expanded(
                  child: _DurationNumberField(
                    controller: _minutesController,
                    label: l10n.customMinutesLabel,
                    suffix: l10n.customMinutesSuffix,
                    validator: (value) => _validateMinutes(value, l10n),
                    onChanged: (value) =>
                        _syncMinutes(int.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(width: CustomDurationLayout.fieldSpacing),
                Expanded(
                  child: _DurationNumberField(
                    controller: _secondsController,
                    label: l10n.customSecondsLabel,
                    suffix: l10n.customSecondsSuffix,
                    validator: (value) => _validateSeconds(value, l10n),
                    onChanged: (value) =>
                        _syncSeconds(int.tryParse(value) ?? 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: _handleConfirm,
          child: Text(l10n.dialogConfirm),
        ),
      ],
    );
  }

  void _handleConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final totalSeconds = _minutesValue * 60 + _secondsValue;
    if (totalSeconds <= 0) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customDurationZeroError)),
      );
      return;
    }
    Navigator.of(context).pop(totalSeconds);
  }

  String? _validateMinutes(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0 || parsed > widget.maxMinutes) {
      return l10n.customMinutesValidator(widget.maxMinutes);
    }
    return null;
  }

  String? _validateSeconds(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 0 || parsed > 59) {
      return l10n.customSecondsValidator;
    }
    return null;
  }

  void _syncMinutes(int value) {
    final constrained = value.clamp(0, widget.maxMinutes).toInt();
    setState(() {
      _minutesValue = constrained;
      final text = _minutesValue.toString();
      if (_minutesController.text != text) {
        _minutesController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  void _syncSeconds(int value) {
    final constrained = value.clamp(0, 59).toInt();
    setState(() {
      _secondsValue = constrained;
      final text = _secondsValue.toString();
      if (_secondsController.text != text) {
        _secondsController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }
}

class _DurationSliderTile extends StatelessWidget {
  const _DurationSliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.descriptionBuilder,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final String Function(int) descriptionBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions > 0 ? divisions : null,
          label: descriptionBuilder(value),
          onChanged: (selected) => onChanged(selected.round()),
        ),
      ],
    );
  }
}

class _DurationNumberField extends StatelessWidget {
  const _DurationNumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}
