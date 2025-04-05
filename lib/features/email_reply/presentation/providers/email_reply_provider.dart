import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';

enum EmailReplyStatus { initial, loading, loaded, error }
enum ReplyTone { formal, casual, apologetic, assertive, friendly } // Enum for tones
enum ReplyDetail { quick, detailed } // Enum for detail level

@immutable
class EmailReplyState {
  final EmailReplyStatus status;
  final String generatedReply;
  final String? errorMessage;
  final String originalEmail; // Keep track for regeneration/modification
  final ReplyTone tone;
  final ReplyDetail detail;

  const EmailReplyState({
    this.status = EmailReplyStatus.initial,
    this.generatedReply = '',
    this.errorMessage,
    this.originalEmail = '',
    this.tone = ReplyTone.friendly, // Default tone
    this.detail = ReplyDetail.quick, // Default detail
  });

  EmailReplyState copyWith({
    EmailReplyStatus? status,
    String? generatedReply,
    String? errorMessage,
    String? originalEmail,
    ReplyTone? tone,
    ReplyDetail? detail,
    bool clearError = false,
  }) {
    return EmailReplyState(
      status: status ?? this.status,
      generatedReply: generatedReply ?? this.generatedReply,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      originalEmail: originalEmail ?? this.originalEmail,
      tone: tone ?? this.tone,
      detail: detail ?? this.detail,
    );
  }
}

class EmailReplyNotifier extends StateNotifier<EmailReplyState> {
  final GeminiService _geminiService;

  EmailReplyNotifier(this._geminiService) : super(const EmailReplyState());

  Future<void> generateReply({
    required String originalEmail,
    required ReplyTone tone,
    required ReplyDetail detail,
  }) async {
    if (originalEmail.trim().isEmpty) {
      state = state.copyWith(
          status: EmailReplyStatus.error, errorMessage: 'Please enter the email content.');
      return;
    }
    state = state.copyWith(
      status: EmailReplyStatus.loading,
      originalEmail: originalEmail,
      tone: tone,
      detail: detail,
      clearError: true,
      generatedReply: '',
    );

    try {
      final toneString = tone.toString().split('.').last; // Get "formal", "casual" etc.
      final detailString = detail == ReplyDetail.quick ? "short and concise" : "detailed and thorough";

      final prompt =
          "Write a ${toneString} email reply to the following message. Make the reply ${detailString}:\n\n"
          "\"\"\"\n${originalEmail}\n\"\"\"\n\nReply:";

      final reply = await _geminiService.generateContent(prompt);
      state = state.copyWith(status: EmailReplyStatus.loaded, generatedReply: reply);
    } catch (e) {
      state = state.copyWith(status: EmailReplyStatus.error, errorMessage: e.toString());
    }
  }

   void regenerateReply() {
     if (state.originalEmail.isNotEmpty) {
        generateReply(
          originalEmail: state.originalEmail,
          tone: state.tone,
          detail: state.detail,
        );
     } else {
        state = state.copyWith(status: EmailReplyStatus.error, errorMessage: "Original email is empty.");
     }
   }

   void modifyToneAndRegenerate(ReplyTone newTone) {
     if (state.originalEmail.isNotEmpty) {
        generateReply(
          originalEmail: state.originalEmail,
          tone: newTone,
          detail: state.detail, // Keep current detail level or allow changing too
        );
     } else {
        state = state.copyWith(status: EmailReplyStatus.error, errorMessage: "Original email is empty.");
     }
   }
    void modifyDetailAndRegenerate(ReplyDetail newDetail) {
     if (state.originalEmail.isNotEmpty) {
        generateReply(
          originalEmail: state.originalEmail,
          tone: state.tone, // Keep current tone
          detail: newDetail,
        );
     } else {
        state = state.copyWith(status: EmailReplyStatus.error, errorMessage: "Original email is empty.");
     }
   }
}

final emailReplyProvider =
    StateNotifierProvider<EmailReplyNotifier, EmailReplyState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return EmailReplyNotifier(geminiService);
});