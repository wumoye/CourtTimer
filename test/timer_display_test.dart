import 'package:courttimer/core/settings/settings_controller.dart';
import 'package:courttimer/core/settings/settings_scope.dart';
import 'package:courttimer/core/settings/settings_storage.dart';
import 'package:courttimer/features/timer/model/timer_state.dart';
import 'package:courttimer/features/timer/presentation/widgets/display/timer_display.dart';
import 'package:courttimer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('paused timer shows a visible pause overlay', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsController(SettingsStorage(prefs));
    await settings.init();
    addTearDown(settings.dispose);

    final pausedState = TimerState.initial().copyWith(isPaused: true);

    await tester.pumpWidget(
      SettingsScope(
        controller: settings,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: TimerDisplay(
              state: pausedState,
              onToggle: () {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('已暂停'), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_outline_rounded), findsOneWidget);
  });
}
