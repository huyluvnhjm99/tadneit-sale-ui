import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_config.dart';
import 'core/utils/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize language service
  await LanguageService.init();

  await AppConfig.initialize(
    environment: Environment.production,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
