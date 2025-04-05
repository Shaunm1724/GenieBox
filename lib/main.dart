import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
//import 'core/theme/theme_provider.dart'; // Import theme provider

// Initialize SharedPreferences globally or pass it down if needed.
// This is a common pattern but consider dependency injection for large apps.
late SharedPreferences sharedPreferences;

Future<void> main() async {
  // Ensure widgets are initialized before accessing SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the provider to use the instance we just created
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const GenieBoxApp(),
    ),
  );
}

// Provider to access SharedPreferences easily
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will throw if accessed before main() finishes, hence the override.
  throw UnimplementedError();
});