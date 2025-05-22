import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languagePrefsKey = 'selected_language';
  static const String defaultLanguage = 'en';

  static final Map<String, Map<String, String>> _translations = <String, Map<String, String>>{};
  static String _currentLanguage = defaultLanguage;

  static String get currentLanguage => _currentLanguage;

  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languagePrefsKey) ?? defaultLanguage;
    await loadLanguage(_currentLanguage);
  }

  static Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    // Save preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefsKey, languageCode);

    _currentLanguage = languageCode;

    await loadLanguage(languageCode);
  }

  static Future<void> loadLanguage(String languageCode) async {
    if (_translations.containsKey(languageCode)) return;

    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Convert all values to strings
      final Map<String, String> stringMap = <String, String>{};
      jsonMap.forEach((String key, value) {
        if (value is String) {
          stringMap[key] = value;
        }
      });

      // Cache translations
      _translations[languageCode] = stringMap;
    } catch (e) {
      if (languageCode != defaultLanguage && _translations.containsKey(defaultLanguage)) {
        return;
      }

      _translations[languageCode] = <String, String>{};
    }
  }

  static String translate(String key, {Map<String, String>? params}) {
    final Map<String, String>? langMap = _translations[_currentLanguage] ??
        _translations[defaultLanguage];

    if (langMap == null) return key;

    String translation = langMap[key] ?? key;

    if (params != null) {
      params.forEach((String paramKey, String paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translation;
  }
}