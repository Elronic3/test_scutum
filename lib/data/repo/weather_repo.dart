import 'dart:convert'; // jsonDecode
import 'package:http/http.dart' as http; // network connect
import 'package:scutum/core/constants/app_constants.dart';
import 'package:scutum/data/models/weather_model.dart';

/// Fetching weather data from network
class WeatherRepo {
  /// Fetching weather data for specific city, returning WeatherModel or exception
  Future<WeatherModel> fetchWeather(String city) async {
    // Constructing URL with params:
    // appid: API key
    // units: metric
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}?q=$city&appid=${AppConstants.weatherApiKey}&units=metric',
    );

    try {
      // GET request
      final response = await http.get(url);

      // Checking for success status code (200)
      if (response.statusCode == 200) {
        // Parsing JSON to Map
        final data = jsonDecode(response.body);
        // Converting Map to Model
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // For network errors
      throw Exception('Failed to fetch weather data: $e');
    }
  }
}
