import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/settings/settings_controller.dart';
import '../../../../../core/settings/settings_scope.dart';
import '../../../../../l10n/app_localizations.dart';
import 'timer_settings_controller.dart';
import 'timer_settings_sections.dart';

class TimerSettingsSheet extends StatefulWidget {
  const TimerSettingsSheet({super.key});

  @override
  State<TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<TimerSettingsSheet> {
  SettingsController? _settings;
  TimerSettingsController? _controller;
  Future<List<String>>? _audioAssetsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = SettingsScope.of(context);
    if (!identical(controller, _settings)) {
      _settings?.removeListener(_handleSettingsChanged);
      _settings = controller;
      _settings?.addListener(_handleSettingsChanged);
      _controller?.disposePreview();
      _controller = TimerSettingsController(settings: controller);
    }
    _audioAssetsFuture ??= _loadAudioAssets(context);
  }

  @override
  void dispose() {
    _controller?.disposePreview();
    _settings?.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final controller = _controller;
    if (settings == null || controller == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: TimerSettingsLayout.sheetPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TimerSettingsLayout.sectionSpacing),
                LanguageSelectorSection(controller: settings, l10n: l10n),
                const SizedBox(height: TimerSettingsLayout.sectionSpacing),
                SpeechModeSelectorSection(controller: settings, l10n: l10n),
                const SizedBox(height: TimerSettingsLayout.sectionSpacing),
                FutureBuilder<List<String>>(
                  future: _audioAssetsFuture,
                  builder: (context, snapshot) {
                    final assets = snapshot.data ?? const <String>[];
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EndSoundSelectorSection(
                          controller: settings,
                          l10n: l10n,
                          assets: assets,
                          isLoading: isLoading,
                          isPreviewing: controller.isPreviewing,
                          onPreview: () => _handlePreview(context),
                          onStopPreview: controller.stopPreview,
                        ),
                        if (snapshot.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.endSoundPreviewError,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: TimerSettingsLayout.noteTopSpacing),
                Text(
                  l10n.speechModeUnavailableNote,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TimerSettingsLayout.noteBottomSpacing),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handlePreview(BuildContext context) async {
    final success = await _controller?.playPreview() ?? false;
    if (!context.mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.endSoundPreviewError)));
    }
  }

  Future<List<String>> _loadAudioAssets(BuildContext context) async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(manifestJson);
    final audioAssets = manifest.keys
        .where(
          (path) =>
              path.startsWith('assets/audio/') &&
              (path.endsWith('.mp3') ||
                  path.endsWith('.wav') ||
                  path.endsWith('.m4a')),
        )
        .toList()
      ..sort();
    return audioAssets;
  }
}
