/// Model for weather data fetched from Api
class WeatherModel {
  final double temperature;
  final String description;
  final String iconCode;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  /// Factory constructor to create model from JSON
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // Extractrion objects of temp + weather data
    final mainData = json['main'];
    final weatherData = (json['weather'] as List)[0];

    return WeatherModel(
      // Converting safely
      temperature: (mainData['temp'] as num).toDouble(),
      description: weatherData['description'],
      iconCode: weatherData['icon'],
    );
  }
}
