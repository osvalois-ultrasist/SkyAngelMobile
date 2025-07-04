import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_alert_request.freezed.dart';

@freezed
class CreateAlertRequest with _$CreateAlertRequest {
  const factory CreateAlertRequest({
    required String tipo,
    required String incidencia,
    required String coordenadas,
    String? comentario,
  }) = _CreateAlertRequest;
}

extension CreateAlertRequestExtension on CreateAlertRequest {
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'incidencia': incidencia,
      'coordenadas': coordenadas,
      if (comentario != null && comentario!.isNotEmpty) 'comentario': comentario,
    };
  }
  
  bool get isValid {
    return tipo.isNotEmpty && 
           incidencia.isNotEmpty && 
           coordenadas.isNotEmpty &&
           _isValidCoordinates(coordenadas);
  }
  
  bool _isValidCoordinates(String coords) {
    try {
      final parts = coords.split(',');
      if (parts.length != 2) return false;
      
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    } catch (e) {
      return false;
    }
  }
}
