class WeatherData {
  final String cityName;
  final String country;
  final double tempC;
  final double tempF;
  final String conditionText;
  final String conditionIconUrl; // Needs 'https:' prefix if URL starts with //
  final double windKph;
  final int humidity;
  final double feelsLikeC;
  final double feelsLikeF;
  final String lastUpdated;
  // Add forecast data list if needed

  WeatherData({
    required this.cityName,
    required this.country,
    required this.tempC,
    required this.tempF,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.windKph,
    required this.humidity,
    required this.feelsLikeC,
    required this.feelsLikeF,
    required this.lastUpdated,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    String iconUrl = current['condition']['icon'];
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl'; // Ensure URL has protocol
    }

    return WeatherData(
      cityName: location['name'] ?? 'Unknown City',
      country: location['country'] ?? 'Unknown Country',
      tempC: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      tempF: (current['temp_f'] as num?)?.toDouble() ?? 0.0,
      conditionText: current['condition']['text'] ?? 'Unknown',
      conditionIconUrl: iconUrl,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      feelsLikeC: (current['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      feelsLikeF: (current['feelslike_f'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: current['last_updated'] ?? '',
    );
  }
}

// Basic structure for forecast (expand as needed)
class ForecastDay {
  final String date;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String conditionIconUrl;

  ForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.conditionIconUrl,
  });

  // Add fromJson factory if parsing forecast data
}