import 'package:flutter/foundation.dart'; // For immutable
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';

enum RecipeStatus { initial, loading, loaded, error }

@immutable
class RecipeState {
  final RecipeStatus status;
  final String generatedRecipe;
  final String? errorMessage;
  final String ingredients; // Keep track of input for regeneration
  final String cuisine;
  final String diet;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.generatedRecipe = '',
    this.errorMessage,
    this.ingredients = '',
    this.cuisine = '',
    this.diet = '',
  });

  RecipeState copyWith({
    RecipeStatus? status,
    String? generatedRecipe,
    String? errorMessage,
    String? ingredients,
    String? cuisine,
    String? diet,
    bool clearError = false, // Helper to easily clear error message
  }) {
    return RecipeState(
      status: status ?? this.status,
      generatedRecipe: generatedRecipe ?? this.generatedRecipe,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      ingredients: ingredients ?? this.ingredients,
      cuisine: cuisine ?? this.cuisine,
      diet: diet ?? this.diet,
    );
  }
}

class RecipeNotifier extends StateNotifier<RecipeState> {
  final GeminiService _geminiService;

  RecipeNotifier(this._geminiService) : super(const RecipeState());

  Future<void> generateRecipe({
    required String ingredients,
    String? cuisine,
    String? diet,
  }) async {
    if (ingredients.trim().isEmpty) {
      state = state.copyWith(
          status: RecipeStatus.error, errorMessage: 'Please enter ingredients.');
      return;
    }
    state = state.copyWith(
      status: RecipeStatus.loading,
      ingredients: ingredients, // Store inputs for potential regeneration
      cuisine: cuisine ?? '',
      diet: diet ?? '',
      clearError: true, // Clear previous error
      generatedRecipe: '', // Clear previous recipe
    );

    try {
      String prompt =
          "Generate a recipe using the following ingredients: $ingredients.";
      if (cuisine != null && cuisine.isNotEmpty) {
        prompt += " Cuisine style: $cuisine.";
      }
      if (diet != null && diet.isNotEmpty) {
        prompt += " Dietary preference: $diet.";
      }
      prompt +=
          "\nFormat the output clearly with:\n1. A catchy Title\n2. Ingredients list\n3. Step-by-step instructions.";

      final recipe = await _geminiService.generateContent(prompt);
      state = state.copyWith(status: RecipeStatus.loaded, generatedRecipe: recipe);
    } catch (e) {
      state = state.copyWith(status: RecipeStatus.error, errorMessage: e.toString());
    }
  }

   Future<void> generateSurpriseRecipe() async {
     state = state.copyWith(
      status: RecipeStatus.loading,
      ingredients: '', // Clear inputs for surprise
      cuisine: '',
      diet: '',
      clearError: true,
      generatedRecipe: '',
    );

    try {
      const String prompt = "Generate a unique and interesting recipe (could be anything!). "
                           "Format the output clearly with:\n1. A catchy Title\n2. Ingredients list\n3. Step-by-step instructions.";

      final recipe = await _geminiService.generateContent(prompt);
      state = state.copyWith(status: RecipeStatus.loaded, generatedRecipe: recipe);
    } catch (e) {
      state = state.copyWith(status: RecipeStatus.error, errorMessage: e.toString());
    }
  }

  void regenerateRecipe() {
     if (state.ingredients.isNotEmpty) {
        generateRecipe(
          ingredients: state.ingredients,
          cuisine: state.cuisine.isNotEmpty ? state.cuisine : null,
          diet: state.diet.isNotEmpty ? state.diet : null,
        );
     } else {
       // If ingredients are empty, maybe trigger surprise or show error
       generateSurpriseRecipe(); // Or: state = state.copyWith(status: RecipeStatus.error, errorMessage: "Cannot regenerate without initial ingredients.");
     }
  }
}

final recipeProvider = StateNotifierProvider<RecipeNotifier, RecipeState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return RecipeNotifier(geminiService);
});