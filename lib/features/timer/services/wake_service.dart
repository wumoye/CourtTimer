import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenWakeService {
  const ScreenWakeService._();

  static Future<void> enable() => WakelockPlus.enable();

  static Future<void> disable() => WakelockPlus.disable();
}
