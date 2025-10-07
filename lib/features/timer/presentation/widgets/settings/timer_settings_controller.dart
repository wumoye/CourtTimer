import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../../core/settings/settings_controller.dart';

class TimerSettingsController extends ChangeNotifier {
  TimerSettingsController({required this.settings});

  final SettingsController settings;

  bool get isPreviewing => _isPreviewing;

  AudioPlayer? _previewPlayer;
  StreamSubscription<void>? _previewCompleteSub;
  StreamSubscription<PlayerState>? _previewStateSub;
  Timer? _previewFallbackTimer;
  bool _isPreviewing = false;

  Future<bool> playPreview() async {
    final asset = settings.endSoundAsset;
    if (asset == null || asset.isEmpty) {
      return false;
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
      _setPreviewing(true);
      await _previewPlayer!.play(AssetSource(relative));
      _previewCompleteSub =
          _previewPlayer!.onPlayerComplete.listen((_) => _resetPreviewFlag());
      _previewStateSub = _previewPlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped || state == PlayerState.completed) {
          _resetPreviewFlag();
        }
      });
      _previewFallbackTimer = Timer(
        const Duration(milliseconds: 1200),
        () => _resetPreviewFlag(),
      );
    } catch (_) {
      _resetPreviewFlag();
      return false;
    }
    return true;
  }

  Future<void> stopPreview() async {
    await _previewPlayer?.stop();
    await _previewCompleteSub?.cancel();
    await _previewStateSub?.cancel();
    _previewFallbackTimer?.cancel();
    _resetPreviewFlag();
  }

  void disposePreview() {
    _previewCompleteSub?.cancel();
    _previewStateSub?.cancel();
    _previewFallbackTimer?.cancel();
    _previewPlayer?.dispose();
  }

  void _setPreviewing(bool value) {
    if (_isPreviewing == value) {
      return;
    }
    _isPreviewing = value;
    notifyListeners();
  }

  void _resetPreviewFlag() {
    _setPreviewing(false);
    _previewCompleteSub?.cancel();
    _previewCompleteSub = null;
    _previewStateSub?.cancel();
    _previewStateSub = null;
    _previewFallbackTimer?.cancel();
    _previewFallbackTimer = null;
  }
}
