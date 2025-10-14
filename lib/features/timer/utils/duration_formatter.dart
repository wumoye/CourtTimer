import 'package:courttimer/core/settings/app_language.dart';

String formatAsDigits(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final capped = safe > 5999 ? 5999 : safe; // 最大显示 99:59
  final minutes = capped ~/ 60;
  final seconds = capped % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String optionLabelFor(AppLanguage language, int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remain = safe % 60;
  switch (language) {
    case AppLanguage.zh:
      if (minutes == 0) {
        return '$remain 秒';
      }
      if (remain == 0) {
        return '$minutes 分钟';
      }
      return '$minutes 分 $remain 秒';
    case AppLanguage.en:
      if (minutes == 0) {
        return '$remain s';
      }
      if (remain == 0) {
        final suffix = minutes == 1 ? '' : 's';
        return '$minutes min$suffix';
      }
      final minuteSuffix = minutes == 1 ? '' : 's';
      return '$minutes min$minuteSuffix $remain s';
    case AppLanguage.ja:
      if (minutes == 0) {
        return '$remain 秒';
      }
      if (remain == 0) {
        return '$minutes 分';
      }
      return '$minutes 分 $remain 秒';
  }
}

String milestoneLabelFor(AppLanguage language, int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remain = safe % 60;
  switch (language) {
    case AppLanguage.zh:
      if (minutes > 0) {
        return '$minutes 分钟';
      }
      return '$remain 秒';
    case AppLanguage.en:
      if (minutes > 0) {
        final suffix = minutes == 1 ? '' : 's';
        return '$minutes min$suffix';
      }
      final suffix = remain == 1 ? '' : 's';
      return '$remain sec$suffix';
    case AppLanguage.ja:
      if (minutes > 0) {
        return '$minutes分';
      }
      return '$remain秒';
  }
}

String speechLabelFor(AppLanguage language, int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remain = safe % 60;

  if (minutes == 0 && remain == 0) {
    return switch (language) {
      AppLanguage.zh => '零秒',
      AppLanguage.en => '0 seconds',
      AppLanguage.ja => '0秒',
    };
  }

  switch (language) {
    case AppLanguage.zh:
      // 中文里在“分钟/秒”之间加入顿号，帮助TTS产生短暂停顿，提高清晰度
      final parts = <String>[];
      if (minutes > 0) {
        parts.add('${speechNumberFor(language, minutes, preferLiang: minutes == 2)}分钟');
      }
      if (remain > 0) {
        parts.add('${speechNumberFor(language, remain, preferLiang: remain == 2)}秒');
      }
      return parts.join('，');
    case AppLanguage.en:
      final parts = <String>[];
      if (minutes > 0) {
        parts.add('$minutes minute${minutes == 1 ? '' : 's'}');
      }
      if (remain > 0) {
        parts.add('$remain second${remain == 1 ? '' : 's'}');
      }
      return parts.join(' ');
    case AppLanguage.ja:
      final parts = <String>[];
      if (minutes > 0) {
        parts.add('$minutes分');
      }
      if (remain > 0) {
        parts.add('$remain秒');
      }
      return parts.join('');
  }
}

String speechNumberFor(
  AppLanguage language,
  int number, {
  bool preferLiang = false,
}) {
  if (number < 0) {
    number = 0;
  }
  switch (language) {
    case AppLanguage.en:
    case AppLanguage.ja:
      return number.toString();
    case AppLanguage.zh:
      const digits = [
        '零',
        '一',
        '二',
        '三',
        '四',
        '五',
        '六',
        '七',
        '八',
        '九',
      ];

      if (number == 0) {
        return '零';
      }
      if (number == 2 && preferLiang) {
        return '两';
      }
      if (number <= 10) {
        if (number == 10) {
          return '十';
        }
        return digits[number];
      }
      if (number < 20) {
        final unit = number % 10;
        return unit == 0 ? '十' : '十${digits[unit]}';
      }
      if (number < 100) {
        final tens = number ~/ 10;
        final unit = number % 10;
        final tensPart = '${digits[tens]}十';
        return unit == 0 ? tensPart : '$tensPart${digits[unit]}';
      }
      return number.toString();
  }
}
