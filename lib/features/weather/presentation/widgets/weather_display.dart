import 'package:flutter/material.dart';
import '../../data/models/weather_data.dart';
import 'package:intl/intl.dart'; // For date formatting

class WeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDisplay({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lastUpdatedTime = DateTime.tryParse(weatherData.lastUpdated);

    return SingleChildScrollView( // Allow scrolling if content overflows
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${weatherData.cityName}, ${weatherData.country}',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (lastUpdatedTime != null)
             Text(
              'Last Updated: ${DateFormat.yMd().add_jm().format(lastUpdatedTime)}',
               style: textTheme.bodySmall,
             ),
          const SizedBox(height: 20),
          Image.network(
             weatherData.conditionIconUrl,
             height: 64,
             width: 64,
             errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, size: 64),
             loadingBuilder: (context, child, loadingProgress) {
               if (loadingProgress == null) return child;
               return const SizedBox(height: 64, width: 64, child: CircularProgressIndicator());
             },
           ),
          Text(
            weatherData.conditionText,
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '${weatherData.tempC.toStringAsFixed(1)}°C',// / ${weatherData.tempF.toStringAsFixed(1)}°F',
            style: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Feels like: ${weatherData.feelsLikeC.toStringAsFixed(1)}°C',// / ${weatherData.feelsLikeF.toStringAsFixed(1)}°F',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
                _buildInfoChip('Wind', '${weatherData.windKph.toStringAsFixed(1)} kph'),
                _buildInfoChip('Humidity', '${weatherData.humidity}%'),
             ],
          ),
          // Add Forecast display here later
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      avatar: Icon(
        label == 'Wind' ? Icons.air : Icons.water_drop_outlined,
        size: 18,
      ),
      label: Text('$label: $value'),
    );
  }
}