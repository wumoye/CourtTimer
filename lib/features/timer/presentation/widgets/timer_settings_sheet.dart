import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/settings/app_language.dart';
import '../../../../core/settings/settings_controller.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/speech_mode.dart';
import '../../../../l10n/app_localizations.dart';

class TimerSettingsSheet extends StatefulWidget {
  const TimerSettingsSheet({super.key});

  @override
  State<TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<TimerSettingsSheet> {
  SettingsController? _settings;
  late Future<List<String>> _audioAssetsFuture;
  bool _assetsInitialized = false;
  AudioPlayer? _previewPlayer;
  StreamSubscription<void>? _previewCompleteSub;
  StreamSubscription<PlayerState>? _previewStateSub;
  Timer? _previewFallbackTimer;
  bool _isPreviewing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = SettingsScope.of(context);
    if (!identical(controller, _settings)) {
      _settings?.removeListener(_handleSettingsChanged);
      _settings = controller;
      _settings?.addListener(_handleSettingsChanged);
    }
    if (!_assetsInitialized) {
      _audioAssetsFuture = _loadAudioAssets();
      _assetsInitialized = true;
    }
  }

  @override
  void dispose() {
    _previewCompleteSub?.cancel();
    _previewStateSub?.cancel();
    _previewFallbackTimer?.cancel();
    _previewPlayer?.dispose();
    _settings?.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings!;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _LanguageSelector(controller: settings, l10n: l10n),
            const SizedBox(height: 20),
            _SpeechModeSelector(controller: settings, l10n: l10n),
            const SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: _audioAssetsFuture,
              builder: (context, snapshot) {
                final assets = snapshot.data ?? const <String>[];
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EndSoundSelector(
                      controller: settings,
                      l10n: l10n,
                      assets: assets,
                      isLoading: isLoading,
                      isPreviewing: _isPreviewing,
                      onPreview: _playPreview,
                      onStopPreview: _stopPreview,
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
            const SizedBox(height: 28),
            Text(
              l10n.speechModeUnavailableNote,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _loadAudioAssets() async {
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

  Future<void> _playPreview() async {
    final asset = _settings?.endSoundAsset;
    final l10n = AppLocalizations.of(context)!;
    if (asset == null || asset.isEmpty) {
      _showSnackBar(l10n.endSoundPreviewError);
      return;
    }

    final relative = asset.startsWith('assets/')
        ? asset.substring('assets/'.length)
        : asset;
    _previewPlayer ??= AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setPlayerMode(PlayerMode.lowLatency);

    try {
      await _previewPlayer!.stop();
      await _previewCompleteSub?.cancel();
      await _previewStateSub?.cancel();
      _previewFallbackTimer?.cancel();
      setState(() => _isPreviewing = true);
      await _previewPlayer!.play(AssetSource(relative));
      _previewCompleteSub =
          _previewPlayer!.onPlayerComplete.listen((_) => _resetPreviewFlag());
      _previewStateSub = _previewPlayer!.onPlayerStateChanged.listen(
        (state) {
          if (state == PlayerState.stopped || state == PlayerState.completed) {
            _resetPreviewFlag();
          }
        },
      );
      _previewFallbackTimer = Timer(
        const Duration(milliseconds: 1200),
        () => _resetPreviewFlag(),
      );
    } catch (_) {
      _resetPreviewFlag(showError: true);
    }
  }

  Future<void> _stopPreview() async {
    await _previewPlayer?.stop();
    await _previewCompleteSub?.cancel();
    await _previewStateSub?.cancel();
    _previewFallbackTimer?.cancel();
    _resetPreviewFlag();
  }

  void _resetPreviewFlag({bool showError = false}) {
    if (mounted) {
      setState(() => _isPreviewing = false);
      _previewCompleteSub?.cancel();
      _previewCompleteSub = null;
      _previewStateSub?.cancel();
      _previewStateSub = null;
      _previewFallbackTimer?.cancel();
      if (showError) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.endSoundPreviewError);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.controller,
    required this.l10n,
  });

  final SettingsController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AppLanguage>(
      value: controller.language,
      decoration: InputDecoration(labelText: l10n.settingsLanguageLabel),
      items: AppLanguage.values
          .map(
            (language) => DropdownMenuItem<AppLanguage>(
              value: language,
              child: Text(_labelFor(language)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.updateLanguage(value);
        }
      },
    );
  }

  String _labelFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.zh:
        return l10n.languageChinese;
      case AppLanguage.en:
        return l10n.languageEnglish;
      case AppLanguage.ja:
        return l10n.languageJapanese;
    }
  }
}

class _SpeechModeSelector extends StatelessWidget {
  const _SpeechModeSelector({
    required this.controller,
    required this.l10n,
  });

  final SettingsController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SpeechMode>(
      value: controller.speechMode,
      decoration: InputDecoration(
        labelText: l10n.settingsSpeechModeLabel,
        helperText: l10n.settingsSpeechModeHelp,
      ),
      items: SpeechMode.values
          .map(
            (mode) => DropdownMenuItem<SpeechMode>(
              value: mode,
              enabled: mode == SpeechMode.systemTts,
              child: Text(_labelFor(mode)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          controller.updateSpeechMode(value);
        }
      },
    );
  }

  String _labelFor(SpeechMode mode) {
    switch (mode) {
      case SpeechMode.systemTts:
        return l10n.speechModeSystem;
      case SpeechMode.offlineAudio:
        return l10n.speechModeOffline;
      case SpeechMode.onlineService:
        return l10n.speechModeOnline;
    }
  }
}

class _EndSoundSelector extends StatelessWidget {
  const _EndSoundSelector({
    required this.controller,
    required this.l10n,
    required this.assets,
    required this.isLoading,
    required this.isPreviewing,
    required this.onPreview,
    required this.onStopPreview,
  });

  final SettingsController controller;
  final AppLocalizations l10n;
  final List<String> assets;
  final bool isLoading;
  final bool isPreviewing;
  final Future<void> Function() onPreview;
  final Future<void> Function() onStopPreview;

  @override
  Widget build(BuildContext context) {
    final menuMaxHeight = math.min(
      MediaQuery.of(context).size.height * 0.45,
      440.0,
    );
    final current = controller.endSoundAsset;
    final isReady = !isLoading;
    final hasCurrent = current != null && assets.contains(current);
    final effectiveValue = isReady && hasCurrent ? current : null;
    if (isReady && current != null && !hasCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updateEndSoundAsset(null);
      });
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.settingsEndSoundLabel,
        helperText: l10n.settingsEndSoundHelp,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: effectiveValue,
                items: _buildItems(context),
                onChanged: isLoading
                    ? null
                    : (value) => controller.updateEndSoundAsset(value),
                menuMaxHeight: menuMaxHeight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: effectiveValue == null || isLoading
                ? null
                : () {
                    if (isPreviewing) {
                      unawaited(onStopPreview());
                    } else {
                      unawaited(onPreview());
                    }
                  },
            icon: Icon(isPreviewing ? Icons.stop : Icons.play_arrow),
            label: Text(
              isPreviewing
                  ? l10n.endSoundPreviewStop
                  : l10n.endSoundPreviewPlay,
            ),
          ),
        ],
      ),
    );
  }

  String _readableName(String path) {
    final segments = path.split('/');
    final fileName = segments.isNotEmpty ? segments.last : path;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  List<DropdownMenuItem<String?>> _buildItems(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );

    final entries = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.endSoundNoneOption),
      ),
    ];

    for (var i = 0; i < assets.length; i++) {
      final path = assets[i];
      entries.add(
        DropdownMenuItem<String?>(
          value: path,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _readableName(path),
                style: const TextStyle(fontFamily: 'RobotoMono'),
              ),
              if (i < assets.length - 1) divider,
            ],
          ),
        ),
      );
    }
    return entries;
  }
}
