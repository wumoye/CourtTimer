import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/timer/presentation/pages/timer_page.dart';

class CourtTimerApp extends StatelessWidget {
  const CourtTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Court Timer',
      theme: AppTheme.buildTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const TimerPage(),
    );
  }
}
