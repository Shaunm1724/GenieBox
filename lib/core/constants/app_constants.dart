class AppConstants {
  // --- API Keys ---
  // Load these securely! e.g., using --dart-define
  // Command line: flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY --dart-define=WEATHER_API_KEY=YOUR_KEY
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY_PLACEHOLDER');
  static const String weatherApiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'YOUR_WEATHERAPI_KEY_PLACEHOLDER');

  // --- API Endpoints ---
  // Adjust Gemini endpoint based on the specific model and API version
  static const String geminiApiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'; // Example endpoint
  static const String weatherApiBaseUrl = 'http://api.weatherapi.com/v1';
  static const String weatherApiCurrentEndpoint = '/current.json';
  static const String weatherApiForecastEndpoint = '/forecast.json'; // Needs days param
}