import 'package:dartz/dartz.dart';
import '../../../../core/error/app_error.dart';
import '../entities/ai_message.dart';
import '../entities/ai_chat_session.dart';

abstract class AiAssistantRepository {
  Future<Either<AppError, AiMessage>> sendMessage({
    required String message,
    required AiChatContext context,
    String? sessionId,
  });

  Future<Either<AppError, AiChatSession>> createChatSession({
    required AiChatContext context,
    String? initialMessage,
  });

  Future<Either<AppError, AiChatSession>> getChatSession(String sessionId);

  Future<Either<AppError, List<AiChatSession>>> getChatHistory({
    int? limit,
    String? userId,
  });

  Future<Either<AppError, AiMessage>> generateSuggestion({
    required AiChatContext context,
    Map<String, dynamic>? additionalData,
  });

  Future<Either<AppError, List<AiMessageAction>>> getQuickActions({
    required AiChatContext context,
  });

  Future<Either<AppError, void>> saveChatSession(AiChatSession session);

  Future<Either<AppError, void>> deleteChatSession(String sessionId);

  Future<Either<AppError, String>> getContextualHelp({
    required AiChatContextType contextType,
    Map<String, dynamic>? currentData,
  });
}