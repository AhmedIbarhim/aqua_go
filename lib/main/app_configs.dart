import '../core/config/networking/endpoints.dart';

enum AppEnvironment {
  dev,
  qa,
  prod;

  bool get isDev => this == AppEnvironment.dev;
  bool get isQa => this == AppEnvironment.qa;
  bool get isProd => this == AppEnvironment.prod;
}

class AppConfigs {
  final String baseUrl;
  final AppEnvironment environment;

  AppConfigs({required this.baseUrl, required this.environment});

  static AppConfigs forEnvironment(AppEnvironment environment) {
    switch (environment) {
      case AppEnvironment.dev:
        return AppConfigs(
          baseUrl: Endpoints.baseUrlDev,
          environment: AppEnvironment.dev,
        );
      case AppEnvironment.qa:
        return AppConfigs(
          baseUrl: Endpoints.baseUrlQa,
          environment: AppEnvironment.qa,
        );
      case AppEnvironment.prod:
        return AppConfigs(
          baseUrl: Endpoints.baseUrl,
          environment: AppEnvironment.prod,
        );
    }
  }
}
