import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app config with the desired environment
  await AppConfig.initialize(
    environment: Environment.development, // Change this to switch environments
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
