import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../features/weather/data/models/weather_data.dart'; // Import model

class WeatherService {
  final String _apiKey = AppConstants.weatherApiKey;
  final String _baseUrl = AppConstants.weatherApiBaseUrl;

  Future<WeatherData> getCurrentWeather(String city) async {
     if (_apiKey == 'YOUR_WEATHERAPI_KEY_PLACEHOLDER' || _apiKey.isEmpty) {
       throw Exception('WeatherAPI Key not configured.');
    }
    final queryParameters = {
      'key': _apiKey,
      'q': city,
      'aqi': 'no', // Air Quality Index (optional)
    };
    final url = Uri.parse('$_baseUrl${AppConstants.weatherApiCurrentEndpoint}')
        .replace(queryParameters: queryParameters);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 400) {
        // Handle specific errors like city not found
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to load weather: ${errorData['error']['message']}');
      }
       else {
        print("Weather API Error: ${response.statusCode} ${response.body}");
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print("Error calling Weather API: $e");
      throw Exception('Failed to connect to Weather service: $e');
    }
  }

  // Add method for forecast API call similarly
  // Future<List<ForecastDay>> getForecast(String city, int days) async { ... }
}

// Riverpod provider
final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());