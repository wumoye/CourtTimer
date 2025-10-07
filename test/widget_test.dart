import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:courttimer/app.dart';
import 'package:courttimer/features/timer/presentation/widgets/common/duration_selector.dart';
import 'package:courttimer/features/timer/presentation/widgets/display/timer_display.dart';

void main() {
  testWidgets('TimerPage renders primary widgets', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final view = tester.view;
    view.physicalSize = const Size(1080, 1920);
    view.devicePixelRatio = 1.0;

    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CourtTimerApp());
    await tester.pump(); // start FutureBuilder
    await tester.pump(const Duration(milliseconds: 200)); // allow init to finish

    expect(find.byType(DurationSelector), findsOneWidget);
    expect(find.byType(TimerDisplay), findsOneWidget);
  });
}
