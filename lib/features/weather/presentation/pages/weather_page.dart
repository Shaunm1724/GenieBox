import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_display.dart'; // Separate widget for display logic

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final _cityController = TextEditingController();
  String _lastSearchedCity = ''; // Store last search to avoid redundant calls

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchWeather() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty && city != _lastSearchedCity) {
       _lastSearchedCity = city;
       // Access the notifier method via ref.read (for actions)
       ref.read(weatherProvider.notifier).fetchWeather(city);
       // Optionally clear keyboard
       FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.watch to rebuild the widget when the state changes
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Check'),
        // Potentially add refresh or auto-detect location button here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchWeather(), // Search on submit
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchWeather,
                  tooltip: 'Search Weather',
                ),
                 // Add IconButton for location detection later
              ],
            ),
            const SizedBox(height: 20),

            // Display Area based on state
            Expanded(
              child: Center(
                child: switch (weatherState.status) {
                   WeatherStatus.initial => const Text('Enter a city to get weather updates.'),
                   WeatherStatus.loading => const CircularProgressIndicator(),
                   WeatherStatus.loaded when weatherState.weatherData != null =>
                      WeatherDisplay(weatherData: weatherState.weatherData!),
                   WeatherStatus.error => Text(
                        'Error: ${weatherState.errorMessage ?? "Unknown error"}',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                   _ => const SizedBox.shrink(), // Default empty case
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}