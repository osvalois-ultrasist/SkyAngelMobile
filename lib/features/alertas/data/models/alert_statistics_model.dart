import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/alert_statistics_entity.dart';

part 'alert_statistics_model.freezed.dart';
part 'alert_statistics_model.g.dart';

@freezed
class AlertStatisticsModel with _$AlertStatisticsModel {
  const factory AlertStatisticsModel({
    required int total,
    required int activas,
    required int resueltas,
    required int falsas,
    @JsonKey(name: 'porTipo') required Map<String, int> porTipo,
    required int recientes,
  }) = _AlertStatisticsModel;

  factory AlertStatisticsModel.fromJson(Map<String, dynamic> json) => _$AlertStatisticsModelFromJson(json);
}

extension AlertStatisticsModelExtension on AlertStatisticsModel {
  AlertStatisticsEntity toEntity() {
    return AlertStatisticsEntity(
      total: total,
      activas: activas,
      resueltas: resueltas,
      falsas: falsas,
      porTipo: porTipo,
      recientes: recientes,
    );
  }
}
