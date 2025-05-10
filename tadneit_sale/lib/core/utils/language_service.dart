import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languagePrefsKey = 'selected_language';
  static const String defaultLanguage = 'en';

  // Cache for loaded translations
  static final Map<String, Map<String, String>> _translations = <String, Map<String, String>>{};
  static String _currentLanguage = defaultLanguage;

  // Get currently selected language
  static String get currentLanguage => _currentLanguage;

  // Initialize the language service
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languagePrefsKey) ?? defaultLanguage;

    // Load translations for current language
    await loadLanguage(_currentLanguage);
  }

  // Switch to a different language
  static Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    // Save preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefsKey, languageCode);

    // Update current language
    _currentLanguage = languageCode;

    // Load translations if not already cached
    await loadLanguage(languageCode);
  }

  // Load translations for a specific language
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
      print('Failed to load language file for $languageCode: $e');
      // Fallback to English if available
      if (languageCode != defaultLanguage && _translations.containsKey(defaultLanguage)) {
        return;
      }
      // Create empty translations if nothing available
      _translations[languageCode] = <String, String>{};
    }
  }

  // Get translation for a key
  static String translate(String key, {Map<String, String>? params}) {
    // Get translations for current language or fallback to default
    final Map<String, String>? langMap = _translations[_currentLanguage] ??
        _translations[defaultLanguage];

    if (langMap == null) return key;

    // Get translation or fallback to key
    String translation = langMap[key] ?? key;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((String paramKey, String paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translation;
  }
}