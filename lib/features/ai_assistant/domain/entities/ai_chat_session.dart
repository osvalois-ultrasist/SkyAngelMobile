import 'package:freezed_annotation/freezed_annotation.dart';
import 'ai_message.dart';

part 'ai_chat_session.freezed.dart';
part 'ai_chat_session.g.dart';

@freezed
class AiChatSession with _$AiChatSession {
  const factory AiChatSession({
    required String id,
    required String title,
    required List<AiMessage> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AiChatContext context,
    @Default(AiChatSessionStatus.active) AiChatSessionStatus status,
    String? userId,
    Map<String, dynamic>? metadata,
  }) = _AiChatSession;

  factory AiChatSession.fromJson(Map<String, dynamic> json) => _$AiChatSessionFromJson(json);
}

@freezed
class AiChatContext with _$AiChatContext {
  const factory AiChatContext({
    required AiChatContextType type,
    required String location,
    Map<String, dynamic>? currentData,
    List<String>? relevantFeatures,
    String? userIntent,
    double? confidenceScore,
  }) = _AiChatContext;

  factory AiChatContext.fromJson(Map<String, dynamic> json) => _$AiChatContextFromJson(json);
}

enum AiChatSessionStatus {
  active,
  paused,
  completed,
  archived,
}

enum AiChatContextType {
  dashboard,
  maps,
  alerts,
  routes,
  profile,
  general,
  emergency,
}

extension AiChatContextTypeExtension on AiChatContextType {
  String get label {
    switch (this) {
      case AiChatContextType.dashboard:
        return 'Dashboard';
      case AiChatContextType.maps:
        return 'Mapas';
      case AiChatContextType.alerts:
        return 'Alertas';
      case AiChatContextType.routes:
        return 'Rutas';
      case AiChatContextType.profile:
        return 'Perfil';
      case AiChatContextType.general:
        return 'General';
      case AiChatContextType.emergency:
        return 'Emergencia';
    }
  }

  String get systemPrompt {
    switch (this) {
      case AiChatContextType.dashboard:
        return 'Eres un asistente especializado en análisis de datos de seguridad. Ayuda al usuario a interpretar estadísticas, tendencias y métricas de seguridad urbana.';
      case AiChatContextType.maps:
        return 'Eres un asistente especializado en análisis geoespacial de seguridad. Ayuda al usuario a interpretar mapas de crimen, zonas de riesgo y patrones geográficos.';
      case AiChatContextType.alerts:
        return 'Eres un asistente especializado en gestión de alertas de seguridad. Ayuda al usuario a crear, gestionar y entender alertas comunitarias.';
      case AiChatContextType.routes:
        return 'Eres un asistente especializado en planificación de rutas seguras. Ayuda al usuario a encontrar las mejores rutas considerando factores de seguridad.';
      case AiChatContextType.profile:
        return 'Eres un asistente personal de seguridad. Ayuda al usuario con configuraciones, preferencias y gestión de su perfil de seguridad.';
      case AiChatContextType.general:
        return 'Eres SkyAngel AI, un asistente inteligente especializado en seguridad urbana y análisis de riesgo. Proporciona información útil y actionable.';
      case AiChatContextType.emergency:
        return 'Eres un asistente de emergencia especializado en seguridad. Proporciona información rápida y precisa para situaciones de riesgo o emergencia.';
    }
  }
}