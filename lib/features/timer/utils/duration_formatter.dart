String formatAsDigits(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final capped = safe > 5999 ? 5999 : safe; // 最大显示 99:59
  final minutes = capped ~/ 60;
  final seconds = capped % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String labelForSeconds(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remain = safe % 60;
  if (minutes == 0) {
    return '$remain 秒';
  }
  if (remain == 0) {
    return '$minutes 分钟';
  }
  return '$minutes 分 $remain 秒';
}

String speechLabelFor(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = safe ~/ 60;
  final remain = safe % 60;

  if (minutes == 0 && remain == 0) {
    return '0 秒';
  }

  final parts = <String>[];
  if (minutes > 0) {
    parts.add('$minutes 分钟');
  }
  if (remain > 0) {
    parts.add('$remain 秒');
  }
  return parts.join('');
}

String speechNumberFor(int number) {
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

  if (number < 0) {
    return '零';
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
