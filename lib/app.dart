// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/recipe/presentation/pages/recipe_creator_page.dart';
import 'features/email_reply/presentation/pages/email_reply_page.dart';
import 'features/story_poem/presentation/pages/story_poem_page.dart';
import 'features/weather/presentation/pages/weather_page.dart';

class GenieBoxApp extends ConsumerWidget {
  const GenieBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'GenieBox',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Simple Navigation using BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Define late because it needs _navigateToIndex which uses setState
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize _widgetOptions here where we can reference _navigateToIndex
    _widgetOptions = <Widget>[
      HomePage(onNavigate: _navigateToIndex), // Pass the callback here
      const RecipeCreatorPage(),
      const EmailReplyPage(),
      const StoryPoemPage(), // Assuming this is the "Create" page at index 3
      const WeatherPage(),
    ];
  }

  // Renamed _onItemTapped to be more generic for navigation requests
  void _navigateToIndex(int index) {
    // Ensure index is valid before changing state
    if (index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      print("Error: Invalid index requested for navigation: $index");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the widget options based on the current index
    final Widget currentPage = (_selectedIndex >= 0 && _selectedIndex < _widgetOptions.length)
        ? _widgetOptions.elementAt(_selectedIndex)
        : const Center(child: Text("Invalid Page Index")); // Fallback

    return Scaffold(
      // The body now correctly shows the widget based on _selectedIndex
      body: IndexedStack( // Use IndexedStack to keep state of inactive pages
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // body: Center( // Original way - works but doesn't preserve state
      //   child: currentPage,
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // Index 0
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Recipe'), // Index 1
          BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Email'), // Index 2
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Create'), // Index 3 (Story/Poem)
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Weather'), // Index 4
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _navigateToIndex, // Use the same method for direct taps
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}