import 'package:flutter/services.dart';

/// Native short vibration used to acknowledge pause and resume on Android.
class PauseResumeVibration {
  PauseResumeVibration._();

  static const MethodChannel _channel = MethodChannel(
    'com.wumoye.courttimer/vibration',
  );

  static Future<void> vibrate() async {
    try {
      await _channel.invokeMethod<void>('pauseResume');
    } on MissingPluginException {
      // Non-Android platforms keep working without a native vibration service.
    } on PlatformException {
      // Vibration is optional feedback and must never interrupt the timer.
    }
  }
}
