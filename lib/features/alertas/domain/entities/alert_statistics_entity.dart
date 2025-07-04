import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_statistics_entity.freezed.dart';

@freezed
class AlertStatisticsEntity with _$AlertStatisticsEntity {
  const factory AlertStatisticsEntity({
    required int total,
    required int activas,
    required int resueltas,
    required int falsas,
    required Map<String, int> porTipo,
    required int recientes,
  }) = _AlertStatisticsEntity;
}

extension AlertStatisticsEntityExtension on AlertStatisticsEntity {
  double get porcentajeActivas => total > 0 ? (activas / total) * 100 : 0;
  double get porcentajeResueltas => total > 0 ? (resueltas / total) * 100 : 0;
  double get porcentajeFalsas => total > 0 ? (falsas / total) * 100 : 0;
  
  String get tipoMasComun {
    if (porTipo.isEmpty) return 'N/A';
    
    final entry = porTipo.entries.reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }
  
  int get alertasUltimas24h => recientes;
  
  bool get hayAlertasRecientes => recientes > 0;
}
