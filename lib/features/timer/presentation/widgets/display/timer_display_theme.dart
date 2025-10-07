import 'package:flutter/material.dart';

/// Styling utilities for the main timer display so visual constants live in
/// one place and can be reused or themed later.
class TimerDisplayTheme {
  static const EdgeInsetsGeometry padding =
      EdgeInsets.symmetric(vertical: 48);
  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(24));
  static const BorderRadius overlayBorderRadius =
      BorderRadius.all(Radius.circular(16));
  static const List<BoxShadow> dropShadow = [
    BoxShadow(
      color: Color(0x8A000000), // Equivalent to Colors.black54.
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  static const Color overlayScrimColor = Color(0xD9000000);

  static BoxDecoration containerDecoration(BuildContext context) {
    return BoxDecoration(
      color: backgroundColor(context),
      borderRadius: borderRadius,
      boxShadow: dropShadow,
    );
  }

  static BoxDecoration overlayDecoration() {
    return const BoxDecoration(
      color: overlayScrimColor,
      borderRadius: overlayBorderRadius,
    );
  }

  static Color backgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (scheme.brightness == Brightness.dark) {
      return const Color(0xFF263238); // Approx. Colors.blueGrey.shade900.
    }
    return scheme.primaryContainer;
  }

  static TextStyle headline(TextTheme textTheme) {
    return (textTheme.headlineLarge ??
            const TextStyle(fontSize: 96, fontWeight: FontWeight.bold))
        .copyWith(
      letterSpacing: 4,
      color: Colors.white,
    );
  }

  static TextStyle overlay(TextStyle headlineStyle) {
    return headlineStyle.copyWith(
      fontSize: 48,
      letterSpacing: 8,
    );
  }

  static TextStyle caption(TextTheme textTheme) {
    return (textTheme.titleMedium ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))
        .copyWith(color: Colors.white70);
  }
}
