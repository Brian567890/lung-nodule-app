import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('zh', 'CN');
  
  Locale get locale => _locale;
  
  LocaleProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'zh';
    final countryCode = prefs.getString('countryCode') ?? 'CN';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    await prefs.setString('countryCode', locale.countryCode ?? '');
    
    notifyListeners();
  }
  
  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'zh') {
      await setLocale(const Locale('en', 'US'));
    } else {
      await setLocale(const Locale('zh', 'CN'));
    }
  }
  
  String get currentLanguageText {
    return _locale.languageCode == 'zh' ? '中文' : 'English';
  }
}