# CourtTimer

CourtTimer is a cross-platform Flutter timer app designed for basketball practice sessions and friendly scrimmages. It combines configurable game clocks with natural-sounding prompts so players can focus on the court instead of the stopwatch.

## Features
- Preset durations (6:00, 1:00, 0:30) plus fully customizable intervals.
- Three-second vocal countdown (3-2-1) before play begins; resumes skip the prestart countdown.
- Speech milestones at selectable checkpoints (120s / 60s / 30s) and optional 10–0 final countdown.
- Screen wake lock while the clock is running so the display always stays visible.
- Quick settings sheet to switch UI language (ZH / EN / JA) and speech mode.
- Basketball-flavoured voice prompts with per-language phrasing (system TTS today, audio packs / online TTS coming soon).
- Configurable end-of-clock whistle: drop audio files under `assets/audio/` and pick them in settings.
- Remembers your last language, voice mode, timer duration, milestones, and whistle across sessions.
- Modularized settings sheet and timer display styling for quick UI tweaks.
- Works on Android handsets and modern browsers (Edge/Chrome); desktop builds are included.

## Requirements
- Flutter SDK ≥ 3.7.2
- Dart SDK (installed with Flutter)
- Platform tooling as needed:
  - Android Studio or command-line Android SDK + ADB
  - Edge/Chrome for web testing
  - (Optional) Xcode on macOS for iOS builds

## Getting Started
```bash
git clone https://github.com/<your-account>/courttimer.git
cd courttimer
flutter pub get
```

## Running the App
```bash
# Android phone (example device id)
flutter run -d CPH2173

# Web (Edge or Chrome)
flutter run -d edge

# Windows desktop
flutter run -d windows
```

## Testing & Quality
```bash
flutter analyze
flutter test
```
Widget tests ensure the main timer page renders, and analyzer keeps the codebase lint-clean.

## Project Structure
```
lib/
 ├─ core/                   # Theme, settings controller/scope
 └─ features/timer/
     ├─ controller/         # TimerController business logic
     ├─ model/              # TimerState, milestone definitions
     ├─ services/           # Speech (flutter_tts) & wake lock helpers
     ├─ presentation/
     │    ├─ pages/         # Top-level screens
     │    └─ widgets/       # Subdivided into display/, settings/, dialogs/, common/
     └─ utils/              # Duration formatting & speech helpers
test/                       # Widget tests
memo.md                     # Running project notes (kept up to date)
```

## Roadmap
- Additional TTS voices / styles.
- Alternate notification modes (vibration, sound effects).
- Tablet/desktop layout refinements and richer localization assets.

## Contributing
Issues and pull requests are welcome. Run `flutter analyze` and `flutter test` before submitting any change.
