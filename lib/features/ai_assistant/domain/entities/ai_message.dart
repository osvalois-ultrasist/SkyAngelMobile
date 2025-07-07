import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

@freezed
class AiMessage with _$AiMessage {
  const factory AiMessage({
    required String id,
    required String content,
    required AiMessageType type,
    required DateTime timestamp,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
    List<AiMessageAction>? quickActions,
    AiMessageStatus? status,
  }) = _AiMessage;

  factory AiMessage.fromJson(Map<String, dynamic> json) => _$AiMessageFromJson(json);
}

@freezed
class AiMessageAction with _$AiMessageAction {
  const factory AiMessageAction({
    required String id,
    required String label,
    required String actionType,
    Map<String, dynamic>? parameters,
  }) = _AiMessageAction;

  factory AiMessageAction.fromJson(Map<String, dynamic> json) => _$AiMessageActionFromJson(json);
}

enum AiMessageType {
  user,
  assistant,
  system,
  suggestion,
  alert,
  recommendation,
}

enum AiMessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

extension AiMessageTypeExtension on AiMessageType {
  String get label {
    switch (this) {
      case AiMessageType.user:
        return 'Usuario';
      case AiMessageType.assistant:
        return 'Asistente';
      case AiMessageType.system:
        return 'Sistema';
      case AiMessageType.suggestion:
        return 'Sugerencia';
      case AiMessageType.alert:
        return 'Alerta';
      case AiMessageType.recommendation:
        return 'Recomendación';
    }
  }

  bool get isFromUser => this == AiMessageType.user;
  bool get isFromAssistant => this == AiMessageType.assistant;
  bool get isSystemMessage => this == AiMessageType.system;
}