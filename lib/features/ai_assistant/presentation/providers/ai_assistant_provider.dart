import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ai_message.dart';
import '../../domain/entities/ai_chat_session.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../../data/repositories/ai_assistant_repository_impl.dart';

part 'ai_assistant_provider.freezed.dart';

@freezed
class AiAssistantState with _$AiAssistantState {
  const factory AiAssistantState({
    @Default([]) List<AiChatSession> sessions,
    AiChatSession? currentSession,
    @Default([]) List<AiMessage> currentMessages,
    @Default(false) bool isLoading,
    @Default(false) bool isTyping,
    @Default(false) bool hasActiveSuggestions,
    @Default([]) List<AiMessageAction> quickActions,
    String? error,
    @Default({}) Map<String, dynamic> contextData,
  }) = _AiAssistantState;
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final AiAssistantRepository _repository;

  AiAssistantNotifier(this._repository) : super(const AiAssistantState());

  Future<void> createNewSession(AiChatContext context, {String? initialMessage}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.createChatSession(
      context: context,
      initialMessage: initialMessage,
    );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (session) {
        state = state.copyWith(
          isLoading: false,
          currentSession: session,
          currentMessages: session.messages,
          sessions: [session, ...state.sessions],
        );
        _loadQuickActions(context);
      },
    );
  }

  Future<void> sendMessage(String message, {Map<String, dynamic>? metadata}) async {
    if (state.currentSession == null) return;

    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      type: AiMessageType.user,
      timestamp: DateTime.now(),
      sessionId: state.currentSession!.id,
      metadata: metadata,
      status: AiMessageStatus.sending,
    );

    // Add user message immediately
    state = state.copyWith(
      currentMessages: [...state.currentMessages, userMessage],
      isTyping: true,
      error: null,
    );

    final result = await _repository.sendMessage(
      message: message,
      context: state.currentSession!.context,
      sessionId: state.currentSession!.id,
    );

    result.fold(
      (error) {
        state = state.copyWith(
          isTyping: false,
          error: error.message,
        );
        // Update user message status to failed
        _updateMessageStatus(userMessage.id, AiMessageStatus.failed);
      },
      (aiResponse) {
        state = state.copyWith(
          isTyping: false,
          currentMessages: [...state.currentMessages, aiResponse],
        );
        // Update user message status to delivered
        _updateMessageStatus(userMessage.id, AiMessageStatus.delivered);
        _updateCurrentSession();
      },
    );
  }

  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getChatSession(sessionId);

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (session) => state = state.copyWith(
        isLoading: false,
        currentSession: session,
        currentMessages: session.messages,
      ),
    );
  }

  Future<void> loadChatHistory() async {
    final result = await _repository.getChatHistory();

    result.fold(
      (error) => state = state.copyWith(error: error.message),
      (sessions) => state = state.copyWith(sessions: sessions),
    );
  }

  Future<void> generateSuggestion(AiChatContext context, {Map<String, dynamic>? data}) async {
    final result = await _repository.generateSuggestion(
      context: context,
      additionalData: data,
    );

    result.fold(
      (error) => state = state.copyWith(error: error.message),
      (suggestion) {
        state = state.copyWith(
          hasActiveSuggestions: true,
          currentMessages: [...state.currentMessages, suggestion],
        );
      },
    );
  }

  Future<void> executeQuickAction(AiMessageAction action) async {
    // Handle quick action execution based on action type
    switch (action.actionType) {
      case 'navigate':
        _handleNavigationAction(action);
        break;
      case 'suggestion':
        _handleSuggestionAction(action);
        break;
      case 'analysis':
        _handleAnalysisAction(action);
        break;
      default:
        // Generic action handling
        break;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuggestions() {
    state = state.copyWith(hasActiveSuggestions: false);
  }

  void updateContextData(Map<String, dynamic> data) {
    state = state.copyWith(contextData: {...state.contextData, ...data});
  }

  Future<void> _loadQuickActions(AiChatContext context) async {
    final result = await _repository.getQuickActions(context: context);

    result.fold(
      (error) => {}, // Silently fail for quick actions
      (actions) => state = state.copyWith(quickActions: actions),
    );
  }

  void _updateMessageStatus(String messageId, AiMessageStatus status) {
    final updatedMessages = state.currentMessages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(status: status);
      }
      return message;
    }).toList();

    state = state.copyWith(currentMessages: updatedMessages);
  }

  void _updateCurrentSession() {
    if (state.currentSession != null) {
      final updatedSession = state.currentSession!.copyWith(
        messages: state.currentMessages,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(currentSession: updatedSession);
      _repository.saveChatSession(updatedSession);
    }
  }

  void _handleNavigationAction(AiMessageAction action) {
    // Implementation for navigation actions
  }

  void _handleSuggestionAction(AiMessageAction action) {
    // Implementation for suggestion actions
  }

  void _handleAnalysisAction(AiMessageAction action) {
    // Implementation for analysis actions
  }
}

// Providers
final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepositoryImpl();
});

final aiAssistantProvider = StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  final repository = ref.watch(aiAssistantRepositoryProvider);
  return AiAssistantNotifier(repository);
});

// Convenience providers
final currentChatSessionProvider = Provider<AiChatSession?>((ref) {
  return ref.watch(aiAssistantProvider).currentSession;
});

final currentMessagesProvider = Provider<List<AiMessage>>((ref) {
  return ref.watch(aiAssistantProvider).currentMessages;
});

final isAiTypingProvider = Provider<bool>((ref) {
  return ref.watch(aiAssistantProvider).isTyping;
});

final quickActionsProvider = Provider<List<AiMessageAction>>((ref) {
  return ref.watch(aiAssistantProvider).quickActions;
});

final hasAiSuggestionsProvider = Provider<bool>((ref) {
  return ref.watch(aiAssistantProvider).hasActiveSuggestions;
});