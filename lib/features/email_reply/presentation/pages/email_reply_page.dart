import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/email_reply_provider.dart';

class EmailReplyPage extends ConsumerStatefulWidget {
  const EmailReplyPage({super.key});

  @override
  ConsumerState<EmailReplyPage> createState() => _EmailReplyPageState();
}

class _EmailReplyPageState extends ConsumerState<EmailReplyPage> {
  final _emailController = TextEditingController();
  final _replyController = TextEditingController(); // For editable reply
  ReplyTone _selectedTone = ReplyTone.friendly; // Default
  ReplyDetail _selectedDetail = ReplyDetail.quick; // Default

  @override
  void dispose() {
    _emailController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _generate() {
     ref.read(emailReplyProvider.notifier).generateReply(
           originalEmail: _emailController.text,
           tone: _selectedTone,
           detail: _selectedDetail,
         );
      FocusScope.of(context).unfocus();
  }

  void _regenerate() {
    ref.read(emailReplyProvider.notifier).regenerateReply();
    FocusScope.of(context).unfocus();
  }

   void _copyReply() {
    Clipboard.setData(ClipboardData(text: _replyController.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply copied to clipboard!')),
      );
    });
  }

  // Update reply controller when state changes
   void _updateReplyController(String newReply) {
     // This prevents cursor jumping if user was editing
     if (_replyController.text != newReply) {
       _replyController.text = newReply;
       // Optionally move cursor to end, or maintain position if needed
       _replyController.selection = TextSelection.fromPosition(TextPosition(offset: _replyController.text.length));
     }
   }


  @override
  Widget build(BuildContext context) {
    // Listen to the state for updates
    ref.listen<EmailReplyState>(emailReplyProvider, (_, next) {
      if (next.status == EmailReplyStatus.loaded) {
        _updateReplyController(next.generatedReply);
      }
      // Optionally clear reply field on error or loading
      if (next.status == EmailReplyStatus.loading || next.status == EmailReplyStatus.error) {
         _updateReplyController('');
      }
    });

    // Watch the state for building UI elements
    final emailState = ref.watch(emailReplyProvider);
    final isLoading = emailState.status == EmailReplyStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Email Reply Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Paste the email or message you want to reply to...',
                labelText: 'Original Message',
                border: OutlineInputBorder(),
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            // --- Tone and Detail Selection ---
            Wrap( // Use Wrap for better spacing on smaller screens
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                 DropdownButton<ReplyTone>(
                   value: _selectedTone,
                   hint: const Text('Select Tone'),
                   onChanged: isLoading ? null : (ReplyTone? newValue) {
                     if (newValue != null) {
                       setState(() => _selectedTone = newValue);
                        // Optional: Regenerate immediately on tone change if a reply exists
                        // if (emailState.generatedReply.isNotEmpty) {
                        //   ref.read(emailReplyProvider.notifier).modifyToneAndRegenerate(newValue);
                        // }
                     }
                   },
                   items: ReplyTone.values.map((ReplyTone tone) {
                     return DropdownMenuItem<ReplyTone>(
                       value: tone,
                       child: Text(tone.toString().split('.').last.capitalize()), // Capitalize first letter
                     );
                   }).toList(),
                 ),
                 SegmentedButton<ReplyDetail>(
                    segments: const <ButtonSegment<ReplyDetail>>[
                        ButtonSegment<ReplyDetail>(value: ReplyDetail.quick, label: Text('Quick')),
                        ButtonSegment<ReplyDetail>(value: ReplyDetail.detailed, label: Text('Detailed')),
                    ],
                    selected: <ReplyDetail>{_selectedDetail},
                    onSelectionChanged: isLoading ? null : (Set<ReplyDetail> newSelection) {
                       setState(() {
                           _selectedDetail = newSelection.first;
                       });
                        // Optional: Regenerate immediately on detail change
                        // if (emailState.generatedReply.isNotEmpty) {
                        //   ref.read(emailReplyProvider.notifier).modifyDetailAndRegenerate(newSelection.first);
                        // }
                    },
                 ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.reply),
              label: const Text('Generate Reply'),
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

            if (emailState.status == EmailReplyStatus.error && emailState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Error: ${emailState.errorMessage}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

             // Display editable reply area only when loading is finished (success or fail but not loading)
             if (!isLoading)
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text("Generated Reply:", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _replyController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          hintText: 'Generated reply will appear here...',
                          border: OutlineInputBorder(),
                        ),
                        // Reply is editable by default
                      ),
                      const SizedBox(height: 8),
                      // Show buttons only if there is a reply generated
                      if (emailState.status == EmailReplyStatus.loaded && emailState.generatedReply.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy Reply',
                              onPressed: _copyReply,
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Regenerate',
                              onPressed: isLoading ? null : _regenerate,
                            ),
                          ],
                        )
                   ],
                 )
          ],
        ),
      ),
    );
  }
}

// Helper extension for capitalization
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}