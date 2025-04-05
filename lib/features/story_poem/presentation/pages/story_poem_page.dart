import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import speech_to_text and permission_handler if implementing voice input
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
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

  // Example moods - replace or expand
  final List<String> _moodOptions = ['Neutral', 'Happy', 'Sad', 'Inspiring', 'Dark', 'Mysterious', 'Romantic', 'Funny'];

  // --- For Voice Input (Optional Bonus) ---
  // late stt.SpeechToText _speech;
  // bool _isListening = false;
  // String _voiceInputText = ''; // Temp storage for voice

  @override
  void initState() {
    super.initState();
    // _speech = stt.SpeechToText(); // Initialize if using voice
  }

  @override
  void dispose() {
    _themeController.dispose();
    // _speech.stop(); // Stop listening if active
    super.dispose();
  }

  // --- Voice Input Logic (Optional Bonus) ---
  /*
  void _listen() async {
    var micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required for voice input.')));
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) {
           print('onError: $val');
            setState(() => _isListening = false);
            _speech.stop();
        }
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
             // Update controller directly or store temporarily
            _themeController.text = val.recognizedWords;
            if(val.finalResult) {
               _isListening = false; // Stop listening UI indication
            }
          }),
          listenFor: const Duration(seconds: 20), // Adjust timeout
          pauseFor: const Duration(seconds: 3), // Pause duration
          localeId: "en_US", // Adjust locale if needed
        );
      } else {
         setState(() => _isListening = false);
         _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
  */

  void _generate() {
    ref.read(storyPoemProvider.notifier).generateCreativeContent(
        mode: _selectedMode,
        theme: _themeController.text,
        mood: _selectedMood,
        length: _selectedLength,
    );
    FocusScope.of(context).unfocus();
  }

   void _regenerate() {
     ref.read(storyPoemProvider.notifier).regenerateContent();
     FocusScope.of(context).unfocus();
   }

   void _copyContent(String content) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard!')),
      );
    });
  }

  // Add _shareContent method using share_plus package if needed
  // Add _saveContent method using shared_preferences or db if needed


  @override
  Widget build(BuildContext context) {
    final creativeState = ref.watch(storyPoemProvider);
    final isLoading = creativeState.status == CreativeStatus.loading;

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
                 ButtonSegment<CreativeMode>(value: CreativeMode.poem, label: Text('Poem'), icon: Icon(Icons.menu_book)),
                 ButtonSegment<CreativeMode>(value: CreativeMode.story, label: Text('Story'), icon: Icon(Icons.auto_stories)),
               ],
               selected: <CreativeMode>{_selectedMode},
               onSelectionChanged: isLoading ? null : (Set<CreativeMode> newSelection) {
                 setState(() => _selectedMode = newSelection.first);
               },
             ),
             const SizedBox(height: 16),

             // --- Theme Input ---
             TextField(
               controller: _themeController,
               decoration: InputDecoration(
                 hintText: 'Enter theme or topic...',
                 labelText: 'Theme / Topic',
                 border: const OutlineInputBorder(),
                  // --- Optional: Voice Input Button ---
                 // suffixIcon: IconButton(
                 //   icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                 //   tooltip: 'Input theme via voice',
                 //   onPressed: isLoading ? null : _listen,
                 // ),
               ),
               enabled: !isLoading,
             ),
             const SizedBox(height: 16),

             // --- Mood & Length Selection ---
             Row(
               children: [
                  Expanded(
                     child: DropdownButtonFormField<String>(
                       value: _selectedMood,
                       hint: const Text('Mood'),
                       onChanged: isLoading ? null : (value) => setState(() => _selectedMood = value ?? 'Neutral'),
                       items: _moodOptions.map((mood) => DropdownMenuItem(value: mood, child: Text(mood))).toList(),
                       decoration: const InputDecoration(border: OutlineInputBorder()),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: DropdownButtonFormField<CreativeLength>(
                       value: _selectedLength,
                       hint: const Text('Length'),
                       onChanged: isLoading ? null : (value) => setState(() => _selectedLength = value ?? CreativeLength.medium),
                       items: CreativeLength.values.map((len) => DropdownMenuItem(
                         value: len,
                         child: Text(len.toString().split('.').last.capitalize())
                       )).toList(),
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                     ),
                   ),
               ],
             ),
             const SizedBox(height: 20),
             ElevatedButton.icon(
                icon: const Icon(Icons.draw),
                label: Text('Generate ${_selectedMode.toString().split('.').last.capitalize()}'),
                onPressed: isLoading ? null : _generate,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
             ),
              const SizedBox(height: 20),

              // --- Output Area ---
               if (isLoading)
                 const Center(child: Padding(
                   padding: EdgeInsets.all(20.0),
                   child: CircularProgressIndicator(),
                 )),

              if (creativeState.status == CreativeStatus.error && creativeState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Error: ${creativeState.errorMessage}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (creativeState.status == CreativeStatus.loaded && creativeState.generatedContent.isNotEmpty)
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
                          SelectableText(creativeState.generatedContent),
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
                                onPressed: isLoading ? null : _regenerate,
                              ),
                              // Add Save/Share buttons here if needed
                              // IconButton(icon: const Icon(Icons.share), tooltip: 'Share', onPressed: _shareContent),
                              // IconButton(icon: const Icon(Icons.save), tooltip: 'Save', onPressed: _saveContent),
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