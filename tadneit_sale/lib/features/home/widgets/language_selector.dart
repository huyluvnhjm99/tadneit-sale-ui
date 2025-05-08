import 'package:flutter/material.dart';

import '../../../core/utils/language_service.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {

  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = LanguageService.currentLanguage;
  }

  void changeLanguage(String? newValue) async {
    if (newValue != null) {
      await LanguageService.setLanguage(newValue);
      setState(() {
        _currentLanguage = LanguageService.currentLanguage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _currentLanguage,
      icon: const Icon(Icons.language),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Theme.of(context).primaryColor,
      ),
      onChanged: changeLanguage,
      items: <String>['en', 'vi'].map<DropdownMenuItem<String>>((String value) {
        String languageName = value == 'en' ? 'English' : 'Tiếng Việt';
        return DropdownMenuItem<String>(
          value: value,
          child: Text(languageName),
        );
      }).toList(),
    );
  }
}