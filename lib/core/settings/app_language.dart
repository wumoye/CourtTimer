import 'package:flutter/material.dart';

enum AppLanguage {
  zh,
  en,
  ja,
}

extension AppLanguageX on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.zh:
        return const Locale('zh', 'CN');
      case AppLanguage.en:
        return const Locale('en', 'US');
      case AppLanguage.ja:
        return const Locale('ja', 'JP');
    }
  }

  String get languageCode {
    switch (this) {
      case AppLanguage.zh:
        return 'zh';
      case AppLanguage.en:
        return 'en';
      case AppLanguage.ja:
        return 'ja';
    }
  }

  String get ttsLocaleTag {
    switch (this) {
      case AppLanguage.zh:
        return 'zh-CN';
      case AppLanguage.en:
        return 'en-US';
      case AppLanguage.ja:
        return 'ja-JP';
    }
  }

  static AppLanguage fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return AppLanguage.zh;
      case 'ja':
        return AppLanguage.ja;
      case 'en':
      default:
        return AppLanguage.en;
    }
  }
}
