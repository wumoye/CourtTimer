import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:courttimer/features/timer/presentation/pages/timer_page.dart';
import 'package:courttimer/features/timer/presentation/widgets/duration_selector.dart';
import 'package:courttimer/features/timer/presentation/widgets/timer_display.dart';

void main() {
  testWidgets('TimerPage 初始渲染包含主要组件', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TimerPage()));

    expect(find.byType(DurationSelector), findsOneWidget);
    expect(find.byType(TimerDisplay), findsOneWidget);
  });
}
