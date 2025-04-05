import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/weather_service.dart';
import '../../data/models/weather_data.dart';

// 1. Define the State
// Using a sealed class or enum for state management is robust
enum WeatherStatus { initial, loading, loaded, error }

class WeatherState {
  final WeatherStatus status;
  final WeatherData? weatherData;
  final String? errorMessage;

  WeatherState({
    this.status = WeatherStatus.initial,
    this.weatherData,
    this.errorMessage,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherData? weatherData,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weatherData: weatherData ?? this.weatherData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}


// 2. Create the Notifier
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _weatherService;

  WeatherNotifier(this._weatherService) : super(WeatherState());

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;
    state = state.copyWith(status: WeatherStatus.loading, errorMessage: null);
    try {
      final weather = await _weatherService.getCurrentWeather(city);
      state = state.copyWith(status: WeatherStatus.loaded, weatherData: weather);
    } catch (e) {
      state = state.copyWith(status: WeatherStatus.error, errorMessage: e.toString());
    }
  }
}

// 3. Define the Provider
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherNotifier(weatherService);
});