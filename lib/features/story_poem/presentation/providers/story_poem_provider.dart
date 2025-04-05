import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';

enum CreativeStatus { initial, loading, loaded, error }
enum CreativeMode { poem, story }
enum CreativeLength { short, medium, long }

@immutable
class StoryPoemState {
  final CreativeStatus status;
  final String generatedContent;
  final String? errorMessage;
  // Store inputs for potential regeneration
  final CreativeMode mode;
  final String theme;
  final String mood; // Using String for flexibility, could be enum
  final CreativeLength length;

  const StoryPoemState({
    this.status = CreativeStatus.initial,
    this.generatedContent = '',
    this.errorMessage,
    this.mode = CreativeMode.poem, // Default mode
    this.theme = '',
    this.mood = 'Neutral', // Default mood
    this.length = CreativeLength.medium, // Default length
  });

  StoryPoemState copyWith({
    CreativeStatus? status,
    String? generatedContent,
    String? errorMessage,
    CreativeMode? mode,
    String? theme,
    String? mood,
    CreativeLength? length,
    bool clearError = false,
  }) {
    return StoryPoemState(
      status: status ?? this.status,
      generatedContent: generatedContent ?? this.generatedContent,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mode: mode ?? this.mode,
      theme: theme ?? this.theme,
      mood: mood ?? this.mood,
      length: length ?? this.length,
    );
  }
}

class StoryPoemNotifier extends StateNotifier<StoryPoemState> {
  final GeminiService _geminiService;

  StoryPoemNotifier(this._geminiService) : super(const StoryPoemState());

  Future<void> generateCreativeContent({
    required CreativeMode mode,
    required String theme,
    required String mood,
    required CreativeLength length,
  }) async {
     if (theme.trim().isEmpty) {
      state = state.copyWith(
          status: CreativeStatus.error, errorMessage: 'Please enter a theme or topic.');
      return;
    }
    state = state.copyWith(
      status: CreativeStatus.loading,
      mode: mode,
      theme: theme,
      mood: mood,
      length: length,
      clearError: true,
      generatedContent: '',
    );

    try {
      final modeString = mode.toString().split('.').last; // "poem" or "story"
      final lengthString = length.toString().split('.').last; // "short", "medium", "long"

      final prompt = "Write a $lengthString $modeString about '$theme' with a '$mood' mood.";

      final content = await _geminiService.generateContent(prompt);
      state = state.copyWith(status: CreativeStatus.loaded, generatedContent: content);
    } catch (e) {
      state = state.copyWith(status: CreativeStatus.error, errorMessage: e.toString());
    }
  }

   void regenerateContent() {
     if (state.theme.isNotEmpty) {
        generateCreativeContent(
          mode: state.mode,
          theme: state.theme,
          mood: state.mood,
          length: state.length,
        );
     } else {
        state = state.copyWith(status: CreativeStatus.error, errorMessage: "Theme is empty, cannot regenerate.");
     }
   }

   // Add methods for save, share later if needed
}

final storyPoemProvider =
    StateNotifierProvider<StoryPoemNotifier, StoryPoemState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return StoryPoemNotifier(geminiService);
});