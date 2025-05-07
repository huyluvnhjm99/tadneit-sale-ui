import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static late String apiBaseUrl;
  static late String appName;
  static late Environment currentEnvironment;

  static Future<void> initialize({
    required Environment environment,
  }) async {
    // Set current environment
    currentEnvironment = environment;

    // Load the appropriate .env file
    String envFile;
    switch (environment) {
      case Environment.development:
        envFile = ".env.development";
        break;
      case Environment.production:
        envFile = ".env.production";
        break;
      case Environment.staging:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    // Load environment variables
    await dotenv.load(fileName: envFile);

    // Initialize configuration
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:7077/api/sss';
    appName = dotenv.env['APP_NAME'] ?? 'TadNeit Sale App';
  }

  // Helper methods
  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
}