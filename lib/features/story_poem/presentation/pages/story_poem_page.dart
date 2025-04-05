import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../providers/story_poem_provider.dart';

class StoryPoemPage extends ConsumerStatefulWidget {
  const StoryPoemPage({super.key});

  @override
  ConsumerState<StoryPoemPage> createState() => _StoryPoemPageState();
}

class _StoryPoemPageState extends ConsumerState<StoryPoemPage> {
  final _themeController = TextEditingController();
  CreativeMode _selectedMode = CreativeMode.poem;
  CreativeLength _selectedLength = CreativeLength.medium;
  String _selectedMood = 'Neutral'; // Default mood

  final List<String> _moodOptions = ['Neutral', 'Happy', 'Sad', 'Inspiring', 'Dark', 'Mysterious', 'Romantic', 'Funny'];

  // --- For Voice Input ---
  late stt.SpeechToText _speech;
  bool _isSpeechInitialized = false; // Track initialization status
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Instance is created
  }

  @override
  void dispose() {
    _themeController.dispose();
    // Stop speech recognition if it's active and initialized
    if (_isSpeechInitialized) {
      _speech.stop();
    }
    super.dispose();
  }

  // --- Voice Input Logic with State Updates ---
  void _listen() async {
    // Request permission first
    var micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Microphone permission required. Please grant it in app settings.')));
      return;
    }

    // --- Start or Stop Listening ---
    if (!_isListening) {
      // Initialize if not already done
      bool available = _isSpeechInitialized; // Assume available if already initialized
      if (!_isSpeechInitialized) {
        available = await _speech.initialize(
          onStatus: (val) {
            print('onStatus: $val');
            // Update listening state based on status notifications
            if (!mounted) return; // Check if widget is still mounted
            if (val == 'listening') {
               if (!_isListening) setState(() => _isListening = true);
            } else { // Includes 'notListening', 'done', 'error'
               if (_isListening) setState(() => _isListening = false);
            }
          },
          onError: (val) {
            print('onError: $val');
            if (!mounted) return;
            setState(() => _isListening = false); // Stop listening on error
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Speech recognition error: ${val.errorMsg}')));
          },
          // debugLog: true, // Uncomment for detailed logs if needed
        );
        if (available) {
          _isSpeechInitialized = true; // Mark as initialized
        }
      }

      if (available) {
        if (!mounted) return;
        // Set state BEFORE calling listen if initialize doesn't immediately trigger onStatus 'listening'
         if (!_isListening) setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) {
             if (!mounted) return;
            // Update the text field as the user speaks
            setState(() {
              _themeController.text = val.recognizedWords;
              _themeController.selection = TextSelection.fromPosition(TextPosition(offset: _themeController.text.length)); // Keep cursor at end
            });
            // Note: finalResult doesn't guarantee listening stops, rely on onStatus
          },
          listenFor: const Duration(seconds: 30), // Increased timeout
          pauseFor: const Duration(seconds: 5),  // Increased pause duration
          localeId: "en_US",
          cancelOnError: true, // Automatically stop on error
          partialResults: true, // Show results progressively
        );
      } else {
        print("Speech recognition not available or initialization failed.");
         if (mounted) setState(() => _isListening = false); // Ensure UI reflects non-listening state
      }
    } else {
      // If already listening, stop it
       if (mounted) setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- Stop listening before generating/regenerating ---
  void _stopListeningIfNeeded() {
    if (_isListening) {
       _speech.stop();
       if (mounted) setState(() => _isListening = false);
    }
  }

  void _generate() {
    _stopListeningIfNeeded(); // Ensure listening stops
    ref.read(storyPoemProvider.notifier).generateCreativeContent(
        mode: _selectedMode,
        theme: _themeController.text,
        mood: _selectedMood,
        length: _selectedLength,
    );
    FocusScope.of(context).unfocus();
  }

  void _regenerate() {
    _stopListeningIfNeeded(); // Ensure listening stops
    ref.read(storyPoemProvider.notifier).regenerateContent();
    FocusScope.of(context).unfocus();
  }

  void _copyContent(String content) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final creativeState = ref.watch(storyPoemProvider);
    final isLoading = creativeState.status == CreativeStatus.loading;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color? iconColor = Theme.of(context).iconTheme.color; // Default icon color

    return Scaffold(
      appBar: AppBar(title: const Text('Poem / Story Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Mode Selection ---
            SegmentedButton<CreativeMode>(
              segments: const <ButtonSegment<CreativeMode>>[
                ButtonSegment<CreativeMode>(
                    value: CreativeMode.poem,
                    label: Text('Poem'),
                    icon: Icon(Icons.menu_book)),
                ButtonSegment<CreativeMode>(
                    value: CreativeMode.story,
                    label: Text('Story'),
                    icon: Icon(Icons.auto_stories)),
              ],
              selected: <CreativeMode>{_selectedMode},
              onSelectionChanged: isLoading || _isListening // Disable while loading or listening
                  ? null
                  : (Set<CreativeMode> newSelection) {
                      setState(() => _selectedMode = newSelection.first);
                    },
            ),
            const SizedBox(height: 16),

            // --- Theme Input ---
            TextField(
              controller: _themeController,
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Enter theme or topic...', // Dynamic hint
                labelText: 'Theme / Topic',
                border: const OutlineInputBorder(),
                // --- Voice Input Button with Indicator ---
                suffixIcon: IconButton(
                  icon: Icon(
                    // Change icon based on listening state
                    _isListening ? Icons.mic : Icons.mic_none,
                    // Change color based on listening state
                    color: _isListening ? primaryColor : iconColor,
                  ),
                  tooltip: _isListening ? 'Stop listening' : 'Input theme via voice',
                  // Disable button while App is loading content, allow while listening (to stop)
                  onPressed: isLoading ? null : _listen,
                ),
              ),
              // Disable text field editing while App is loading OR listening (optional, but prevents conflicts)
              enabled: !isLoading && !_isListening,
            ),
            const SizedBox(height: 16),

            // --- Mood & Length Selection ---
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMood,
                    hint: const Text('Mood'),
                    // Disable while loading or listening
                    onChanged: isLoading || _isListening
                        ? null
                        : (value) => setState(() => _selectedMood = value ?? 'Neutral'),
                    items: _moodOptions
                        .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
                        .toList(),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CreativeLength>(
                    value: _selectedLength,
                    hint: const Text('Length'),
                    // Disable while loading or listening
                    onChanged: isLoading || _isListening
                        ? null
                        : (value) => setState(() => _selectedLength = value ?? CreativeLength.medium),
                    items: CreativeLength.values
                        .map((len) => DropdownMenuItem(
                            value: len,
                            child: Text(len.toString().split('.').last.capitalize())))
                        .toList(),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.draw),
              label: Text('Generate ${_selectedMode.toString().split('.').last.capitalize()}'),
              // Disable while loading OR listening
              onPressed: isLoading || _isListening ? null : _generate,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(height: 20),

            // --- Output Area ---
            if (isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )),

            if (creativeState.status == CreativeStatus.error &&
                creativeState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Error: ${creativeState.errorMessage}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            if (creativeState.status == CreativeStatus.loaded &&
                creativeState.generatedContent.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Generated Content",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(height: 20),
                      MarkdownBody(
                        data: creativeState.generatedContent,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy',
                            onPressed: () => _copyContent(creativeState.generatedContent),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Regenerate',
                            // Disable while loading OR listening
                            onPressed: isLoading || _isListening ? null : _regenerate,
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

// Re-use or move capitalize extension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}