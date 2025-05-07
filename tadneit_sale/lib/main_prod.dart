import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.initialize(
    environment: Environment.production,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
