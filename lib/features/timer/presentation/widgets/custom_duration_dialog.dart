import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';

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
            Text(l10n.customMinutesLabel),
            Slider(
              value: _minutesValue.toDouble(),
              min: 0,
              max: widget.maxMinutes.toDouble(),
              divisions: widget.maxMinutes,
              label: l10n.customMinutesSliderLabel(_minutesValue),
              onChanged: (value) => _syncMinutes(value.round()),
            ),
            const SizedBox(height: 8),
            Text(l10n.customSecondsLabel),
            Slider(
              value: _secondsValue.toDouble(),
              min: 0,
              max: 59,
              divisions: 59,
              label: l10n.customSecondsSliderLabel(_secondsValue),
              onChanged: (value) => _syncSeconds(value.round()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minutesController,
                    decoration: InputDecoration(
                      labelText: l10n.customMinutesLabel,
                      suffixText: l10n.customMinutesSuffix,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null ||
                          parsed < 0 ||
                          parsed > widget.maxMinutes) {
                        return l10n.customMinutesValidator(widget.maxMinutes);
                      }
                      return null;
                    },
                    onChanged: (value) =>
                        _syncMinutes(int.tryParse(value) ?? 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _secondsController,
                    decoration: InputDecoration(
                      labelText: l10n.customSecondsLabel,
                      suffixText: l10n.customSecondsSuffix,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed < 0 || parsed > 59) {
                        return l10n.customSecondsValidator;
                      }
                      return null;
                    },
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
