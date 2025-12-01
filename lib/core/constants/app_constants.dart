import 'package:scutum/core/constants/env.dart';

class AppConstants {
  // Map Weather
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String weatherApiKey = openWeatherApiKey;
  static const String defaultCity = 'Kyiv';

  // Storage
  static const String taskStorageKey = 'tasks_local_data';

  // UI
  static const double padding = 20.0;
  static const double margin = 16.0;
  static const double borderRadius = 16.0;
}
