import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/settings/app_language.dart';
import 'core/settings/settings_controller.dart';
import 'core/settings/settings_scope.dart';
import 'core/settings/settings_storage.dart';
import 'core/settings/speech_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/timer/presentation/pages/timer_page.dart';
import 'features/timer/services/speech_service.dart';
import 'l10n/app_localizations.dart';

class CourtTimerApp extends StatefulWidget {
  const CourtTimerApp({super.key});

  @override
  State<CourtTimerApp> createState() => _CourtTimerAppState();
}

class _CourtTimerAppState extends State<CourtTimerApp> {
  SettingsController? _settings;
  SpeechService? _speech;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = SettingsStorage(prefs);
    final settings = SettingsController(storage);
    await settings.init();
    final speech = SpeechService(settings: settings);
    _settings = settings;
    _speech = speech;
  }

  @override
  void dispose() {
    _speech?.dispose();
    _settings?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(Brightness.dark),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final settings = _settings!;
        final speech = _speech!;

        return SettingsScope(
          controller: settings,
          child: SpeechScope(
            service: speech,
            child: AnimatedBuilder(
              animation: settings,
              builder: (context, _) {
                return MaterialApp(
                  locale: settings.language.locale,
                  supportedLocales:
                      AppLanguage.values.map((language) => language.locale),
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  theme: AppTheme.buildTheme(Brightness.dark),
                  debugShowCheckedModeBanner: false,
                  home: const TimerPage(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
