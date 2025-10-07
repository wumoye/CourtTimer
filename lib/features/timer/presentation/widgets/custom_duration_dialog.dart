import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> showCustomDurationDialog({
  required BuildContext context,
  required int initialSeconds,
  int maxMinutes = 20,
}) async {
  final initialMinutes = (initialSeconds ~/ 60).clamp(0, maxMinutes);
  final initialRemain = (initialSeconds % 60).clamp(0, 59);

  final minutesController = TextEditingController(
    text: initialMinutes.toString(),
  );
  final secondsController = TextEditingController(
    text: initialRemain.toString(),
  );
  final formKey = GlobalKey<FormState>();

  int minutesValue = initialMinutes;
  int secondsValue = initialRemain;

  final result = await showDialog<int>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          void syncMinutes(int value) {
            final constrained = value.clamp(0, maxMinutes);
            setState(() {
              minutesValue = constrained;
              final text = minutesValue.toString();
              if (minutesController.text != text) {
                minutesController.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }
            });
          }

          void syncSeconds(int value) {
            final constrained = value.clamp(0, 59);
            setState(() {
              secondsValue = constrained;
              final text = secondsValue.toString();
              if (secondsController.text != text) {
                secondsController.value = TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }
            });
          }

          return AlertDialog(
            title: const Text('自定义倒计时'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('分钟： 分'),
                  Slider(
                    value: minutesValue.toDouble(),
                    min: 0,
                    max: maxMinutes.toDouble(),
                    divisions: maxMinutes,
                    label: ' 分',
                    onChanged: (value) => syncMinutes(value.round()),
                  ),
                  const SizedBox(height: 8),
                  Text('秒： 秒'),
                  Slider(
                    value: secondsValue.toDouble(),
                    min: 0,
                    max: 59,
                    divisions: 59,
                    label: ' 秒',
                    onChanged: (value) => syncSeconds(value.round()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: minutesController,
                          decoration: const InputDecoration(
                            labelText: '分钟',
                            suffixText: '分',
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
                                parsed > maxMinutes) {
                              return '0-';
                            }
                            return null;
                          },
                          onChanged:
                              (value) => syncMinutes(int.tryParse(value) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: secondsController,
                          decoration: const InputDecoration(
                            labelText: '秒',
                            suffixText: '秒',
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
                              return '0-59';
                            }
                            return null;
                          },
                          onChanged:
                              (value) => syncSeconds(int.tryParse(value) ?? 0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final totalSeconds = minutesValue * 60 + secondsValue;
                    if (totalSeconds <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('倒计时总时长必须大于 0')),
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(totalSeconds);
                  }
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
    },
  );

  minutesController.dispose();
  secondsController.dispose();
  return result;
}
