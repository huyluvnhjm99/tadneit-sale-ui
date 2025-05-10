import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/src/router.dart';
import 'package:tadneit_sale/core/utils/api_error_handler.dart';
import '../data/providers/message_provider.dart';
import '../presentation/routes/router.dart';
import '../presentation/themes/app_theme.dart';
import 'app_config.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (BuildContext context, Widget? child) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final String? message = ref.watch(messageProvider);

            // Show SnackBar when message changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (message != null) {
                ApiErrorHandler.showSuccessSnackBar(context, message);
                // Clear message after showing
                ref.read(messageProvider.notifier).state = null;
              }
            });

            // Return app child (the routed page)
            return child!;
          },
        );
      },
    );
  }
}