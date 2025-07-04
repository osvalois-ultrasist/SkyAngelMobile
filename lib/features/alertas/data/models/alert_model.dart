import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/alert_entity.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required int id,
    required String tipo,
    required String incidencia,
    required String coordenadas,
    required double lat,
    required double lng,
    required String comentario,
    required DateTime fecha,
    required bool activa,
    @JsonKey(name: 'usuario_id') required int usuarioId,
    required String uuid,
    required String prioridad,
    required String estado,
    @JsonKey(name: 'fecha_actualizacion') DateTime? fechaActualizacion,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) => _$AlertModelFromJson(json);
}

extension AlertModelExtension on AlertModel {
  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      tipo: AlertType.values.firstWhere(
        (e) => e.name.toLowerCase() == tipo.toLowerCase(),
        orElse: () => AlertType.otro,
      ),
      incidencia: incidencia,
      coordenadas: AlertCoordinates(lat: lat, lng: lng),
      comentario: comentario,
      fecha: fecha,
      activa: activa,
      usuarioId: usuarioId,
      uuid: uuid,
      prioridad: AlertPriority.values.firstWhere(
        (e) => e.name.toLowerCase() == prioridad.toLowerCase(),
        orElse: () => AlertPriority.media,
      ),
      estado: AlertStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == estado.toLowerCase(),
        orElse: () => AlertStatus.activa,
      ),
      fechaActualizacion: fechaActualizacion,
    );
  }
}
