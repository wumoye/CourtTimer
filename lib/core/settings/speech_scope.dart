import 'package:flutter/widgets.dart';

import '../../features/timer/services/speech_service.dart';

class SpeechScope extends InheritedWidget {
  const SpeechScope({
    super.key,
    required this.service,
    required super.child,
  });

  final SpeechService service;

  static SpeechService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SpeechScope>();
    assert(scope != null, 'SpeechScope not found in context');
    return scope!.service;
  }

  @override
  bool updateShouldNotify(covariant SpeechScope oldWidget) => false;
}
