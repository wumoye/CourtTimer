import 'package:flutter/material.dart';

import '../../model/timer_state.dart';
import '../../utils/duration_formatter.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    super.key,
    required this.state,
    required this.onToggle,
    required this.onReset,
  });

  final TimerState state;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final color = Colors.blueGrey.shade900;
    final isPrestart = state.isPrestart && state.prestartCount != null;
    final displayText =
        isPrestart
            ? state.prestartCount!.toString()
            : formatAsDigits(state.remainingSeconds);
    final caption = _buildCaption();

    final textTheme = Theme.of(context).textTheme;
    final headlineStyle =
        textTheme.headlineLarge?.copyWith(
          letterSpacing: 4,
          color: Colors.white,
        ) ??
        const TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: Colors.white,
        );
    final captionStyle =
        textTheme.titleMedium?.copyWith(color: Colors.white70) ??
        const TextStyle(color: Colors.white70);

    return GestureDetector(
      onTap: onToggle,
      onLongPress: onReset,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(displayText, style: headlineStyle),
            const SizedBox(height: 16),
            Text(caption, style: captionStyle),
          ],
        ),
      ),
    );
  }

  String _buildCaption() {
    if (state.isPrestart && state.prestartCount != null) {
      return '预备 ';
    }
    if (state.isRunning) {
      return '轻触暂停 / 长按重置';
    }
    if (state.isCompleted) {
      return '已结束，轻触开始 / 长按重置';
    }
    return '轻触开始 / 长按重置';
  }
}
