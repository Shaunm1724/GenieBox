// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date/time formatting

// Import providers and pages
import '../../../../core/theme/theme_provider.dart';
import '../../../recipe/presentation/pages/recipe_creator_page.dart';
import '../../../email_reply/presentation/pages/email_reply_page.dart';
import '../../../story_poem/presentation/pages/story_poem_page.dart';
import '../../../weather/presentation/pages/weather_page.dart';
import '../widgets/feature_tile.dart'; // Import the tile widget

class HomePage extends ConsumerWidget {
  final Function(int) onNavigate;

  const HomePage({
    super.key,
    required this.onNavigate, // Make it required
  });

  // Helper function to get time-based greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Placeholder for quote - replace with actual logic if needed
  String _getQuoteOfTheDay() {
    // Simple example: Cycle through a few quotes based on the day of the week
    final dayOfWeek = DateTime.now().weekday;
    const quotes = [
      "The best way to predict the future is to create it.", // Mon
      "Simplicity is the ultimate sophistication.", // Tue
      "Strive not to be a success, but rather to be of value.", // Wed
      "The mind is everything. What you think you become.", // Thu
      "Creativity takes courage.", // Fri
      "Make each day your masterpiece.", // Sat
      "The journey of a thousand miles begins with one step." // Sun
    ];
    return quotes[dayOfWeek - 1]; // Weekday is 1-7
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final greeting = _getGreeting();
    final quote = _getQuoteOfTheDay(); // Get the quote

    // Define the features to display
    final features = [
      {
        'icon': Icons.restaurant_menu,
        'title': 'Create Recipe',
        'subtitle': 'Generate recipes from ingredients',
        'page': const RecipeCreatorPage(),
        'targetIndex': 1,
        'color': Colors.orange[700],
      },
      {
        'icon': Icons.edit,
        'title': 'Story / Poem',
        'subtitle': 'Generate creative writing',
        'page': const StoryPoemPage(),
        'targetIndex': 3,
        'color': Colors.deepPurple[400],
      },
      {
        'icon': Icons.reply,
        'title': 'Email Reply',
        'subtitle': 'Craft email responses',
        'page': const EmailReplyPage(),
        'targetIndex': 2,
        'color': Colors.blue[600],
      },
      {
        'icon': Icons.cloud_outlined,
        'title': 'Check Weather',
        'subtitle': 'Get current forecast',
        'page': const WeatherPage(),
        'targetIndex': 4,
        'color': Colors.lightBlue[400],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$greeting!'), // Removed placeholder name for simplicity
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Toggle Theme',
            onPressed: () => themeNotifier.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView( // Allows scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Optional: Quote of the day banner
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '"$quote"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)
                      ),
                ),
              ),

              // GridView for Feature Tiles
              GridView.builder(
                shrinkWrap: true, // Important inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 16.0, // Spacing between columns
                  mainAxisSpacing: 16.0, // Spacing between rows
                  childAspectRatio: 1.0, // Adjust aspect ratio (width/height) if needed
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return FeatureTile(
                    icon: feature['icon'] as IconData,
                    title: feature['title'] as String,
                    subtitle: feature['subtitle'] as String,
                    iconColor: feature['color'] as Color?, // Pass color
                    onTap: () {
                      // Navigate to the corresponding feature page
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => feature['page'] as Widget),
                      // );
                      onNavigate(feature['targetIndex'] as int);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}