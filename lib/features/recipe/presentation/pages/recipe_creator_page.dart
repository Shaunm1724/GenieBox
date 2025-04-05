import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_provider.dart';

class RecipeCreatorPage extends ConsumerStatefulWidget {
  const RecipeCreatorPage({super.key});

  @override
  ConsumerState<RecipeCreatorPage> createState() => _RecipeCreatorPageState();
}

class _RecipeCreatorPageState extends ConsumerState<RecipeCreatorPage> {
  final _ingredientsController = TextEditingController();
  String? _selectedCuisine; // Example: Can use Dropdown or Chips
  String? _selectedDiet; // Example: Can use Dropdown or Chips

  // Example options - replace with your actual lists
  final List<String> _cuisineOptions = ['Italian', 'Mexican', 'Indian', 'Chinese', 'Any'];
  final List<String> _dietOptions = ['Vegetarian', 'Vegan', 'Gluten-Free', 'None'];

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _generate() {
    ref.read(recipeProvider.notifier).generateRecipe(
          ingredients: _ingredientsController.text,
          cuisine: _selectedCuisine == 'Any' ? null : _selectedCuisine,
          diet: _selectedDiet == 'None' ? null : _selectedDiet,
        );
     FocusScope.of(context).unfocus(); // Hide keyboard
  }

  void _surpriseMe() {
     _ingredientsController.clear();
     _selectedCuisine = null;
     _selectedDiet = null;
     // Maybe reset dropdowns visually if needed here
     setState(() {}); // To update dropdown display if needed
     ref.read(recipeProvider.notifier).generateSurpriseRecipe();
     FocusScope.of(context).unfocus();
  }

   void _regenerate() {
    ref.read(recipeProvider.notifier).regenerateRecipe();
     FocusScope.of(context).unfocus();
  }

  void _copyRecipe(String recipeText) {
    Clipboard.setData(ClipboardData(text: recipeText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe copied to clipboard!')),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeProvider);
    final isLoading = recipeState.status == RecipeStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create a Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ingredientsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter ingredients, separated by commas or new lines...',
                labelText: 'Ingredients',
                border: OutlineInputBorder(),
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            // --- Optional Inputs ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align tops if they have different heights due to errors etc.
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCuisine,
                    hint: const Text('Cuisine(Optional)'), // Consider slightly shorter hint if needed
                    isExpanded: true,
                    onChanged: isLoading ? null : (value) => setState(() => _selectedCuisine = value),
                    items: _cuisineOptions.map((cuisine) => DropdownMenuItem(value: cuisine, child: Text(cuisine))).toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0), // Optional: Adjust padding if needed
                    ),
                  ),
                ),
                const SizedBox(width: 8), // <-- REDUCE SPACING (e.g., from 16 to 8)
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDiet,
                    hint: const Text('Diet (Optional)'), // Consider slightly shorter hint if needed
                    isExpanded: true,
                    onChanged: isLoading ? null : (value) => setState(() => _selectedDiet = value),
                    items: _dietOptions.map((diet) => DropdownMenuItem(value: diet, child: Text(diet))).toList(),
                     decoration: const InputDecoration(
                       border: OutlineInputBorder(),
                       contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0), // Optional: Adjust padding if needed
                     ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // --- Action Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 ElevatedButton.icon(
                   icon: const Icon(Icons.auto_fix_high),
                   label: const Text('Generate'),
                   onPressed: isLoading ? null : _generate,
                   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                 ),
                 ElevatedButton.icon(
                   icon: const Icon(Icons.shuffle),
                   label: const Text('Surprise Me'),
                   onPressed: isLoading ? null : _surpriseMe,
                   style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                 ),
              ],
            ),
             const SizedBox(height: 20),

            // --- Output Area ---
            if (isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )),

            if (recipeState.status == RecipeStatus.error && recipeState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Error: ${recipeState.errorMessage}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            if (recipeState.status == RecipeStatus.loaded && recipeState.generatedRecipe.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Generated Recipe",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(height: 20),
                      SelectableText(recipeState.generatedRecipe), // Make text selectable
                      const SizedBox(height: 10),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           IconButton(
                             icon: const Icon(Icons.copy),
                             tooltip: 'Copy Recipe',
                             onPressed: () => _copyRecipe(recipeState.generatedRecipe),
                           ),
                           IconButton(
                             icon: const Icon(Icons.refresh),
                             tooltip: 'Regenerate',
                             onPressed: isLoading ? null : _regenerate,
                           ),
                         ],
                       )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}