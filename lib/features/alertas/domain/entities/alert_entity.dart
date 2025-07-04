import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_entity.freezed.dart';

enum AlertType {
  robo,
  accidente,
  violencia,
  emergencia,
  otro,
}

enum AlertPriority {
  baja,
  media,
  alta,
  critica,
}

enum AlertStatus {
  activa,
  resuelta,
  falsa,
}

@freezed
class AlertCoordinates with _$AlertCoordinates {
  const factory AlertCoordinates({
    required double lat,
    required double lng,
  }) = _AlertCoordinates;
}

@freezed
class AlertEntity with _$AlertEntity {
  const factory AlertEntity({
    required int id,
    required AlertType tipo,
    required String incidencia,
    required AlertCoordinates coordenadas,
    required String comentario,
    required DateTime fecha,
    required bool activa,
    required int usuarioId,
    required String uuid,
    required AlertPriority prioridad,
    required AlertStatus estado,
    DateTime? fechaActualizacion,
  }) = _AlertEntity;
}

extension AlertEntityExtension on AlertEntity {
  String get tipoString => tipo.name.toLowerCase();
  String get prioridadString => prioridad.name.toLowerCase();
  String get estadoString => estado.name.toLowerCase();
  String get coordenadasString => '${coordenadas.lat},${coordenadas.lng}';
  
  bool get isHighPriority => prioridad == AlertPriority.alta || prioridad == AlertPriority.critica;
  bool get isActive => activa && estado == AlertStatus.activa;
  
  Duration get timeElapsed => DateTime.now().difference(fecha);
  
  String get formattedTimeElapsed {
    final elapsed = timeElapsed;
    if (elapsed.inMinutes < 1) {
      return 'Hace menos de un minuto';
    } else if (elapsed.inHours < 1) {
      return 'Hace ${elapsed.inMinutes} minuto${elapsed.inMinutes > 1 ? 's' : ''}';
    } else if (elapsed.inDays < 1) {
      return 'Hace ${elapsed.inHours} hora${elapsed.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${elapsed.inDays} día${elapsed.inDays > 1 ? 's' : ''}';
    }
  }
}
