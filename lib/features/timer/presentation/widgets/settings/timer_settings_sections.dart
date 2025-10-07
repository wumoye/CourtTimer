import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/settings/app_language.dart';
import '../../../../../core/settings/settings_controller.dart';
import '../../../../../core/settings/speech_mode.dart';
import '../../../../../l10n/app_localizations.dart';

/// Centralised layout metrics for the timer settings UI so that spacing and
/// padding live in a single place.
class TimerSettingsLayout {
  static const EdgeInsets sheetPadding =
      EdgeInsets.fromLTRB(24, 24, 24, 32);

  static const double sectionSpacing = 20;
  static const double noteTopSpacing = 28;
  static const double noteBottomSpacing = 8;
  static const double previewButtonGap = 12;

  static double menuMaxHeight(BuildContext context) {
    return math.min(MediaQuery.of(context).size.height * 0.45, 440.0);
  }
}

class LanguageSelectorSection extends StatelessWidget {
  const LanguageSelectorSection({
    super.key,
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

class SpeechModeSelectorSection extends StatelessWidget {
  const SpeechModeSelectorSection({
    super.key,
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

class EndSoundSelectorSection extends StatelessWidget {
  const EndSoundSelectorSection({
    super.key,
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
                menuMaxHeight: TimerSettingsLayout.menuMaxHeight(context),
              ),
            ),
          ),
          const SizedBox(width: TimerSettingsLayout.previewButtonGap),
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

  String _readableName(String path) {
    final segments = path.split('/');
    final fileName = segments.isNotEmpty ? segments.last : path;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }
}
