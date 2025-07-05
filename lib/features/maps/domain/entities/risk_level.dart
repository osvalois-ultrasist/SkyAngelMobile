import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'risk_level.freezed.dart';

enum RiskLevelType {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
  extreme,
}

@freezed
class RiskLevel with _$RiskLevel {
  const factory RiskLevel({
    required RiskLevelType level,
    required String label,
    required String description,
    required Color color,
    required double minValue,
    required double maxValue,
    required int priority,
  }) = _RiskLevel;
}

extension RiskLevelExtension on RiskLevelType {
  static RiskLevelType fromValue(double value) {
    if (value <= 0.1) return RiskLevelType.veryLow;
    if (value <= 0.3) return RiskLevelType.low;
    if (value <= 0.5) return RiskLevelType.moderate;
    if (value <= 0.7) return RiskLevelType.high;
    if (value <= 0.9) return RiskLevelType.veryHigh;
    return RiskLevelType.extreme;
  }

  String get label {
    switch (this) {
      case RiskLevelType.veryLow:
        return 'Muy Bajo';
      case RiskLevelType.low:
        return 'Bajo';
      case RiskLevelType.moderate:
        return 'Moderado';
      case RiskLevelType.high:
        return 'Alto';
      case RiskLevelType.veryHigh:
        return 'Muy Alto';
      case RiskLevelType.extreme:
        return 'Extremo';
    }
  }

  String get description {
    switch (this) {
      case RiskLevelType.veryLow:
        return 'Zona muy segura con incidencias mínimas';
      case RiskLevelType.low:
        return 'Zona segura con pocas incidencias';
      case RiskLevelType.moderate:
        return 'Zona con riesgo moderado';
      case RiskLevelType.high:
        return 'Zona de alto riesgo, precaución recomendada';
      case RiskLevelType.veryHigh:
        return 'Zona muy peligrosa, evitar si es posible';
      case RiskLevelType.extreme:
        return 'Zona extremadamente peligrosa, evitar completamente';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevelType.veryLow:
        return const Color(0xFF4CAF50); // Verde
      case RiskLevelType.low:
        return const Color(0xFF8BC34A); // Verde claro
      case RiskLevelType.moderate:
        return const Color(0xFFFFEB3B); // Amarillo
      case RiskLevelType.high:
        return const Color(0xFFFF9800); // Naranja
      case RiskLevelType.veryHigh:
        return const Color(0xFFFF5722); // Naranja rojizo
      case RiskLevelType.extreme:
        return const Color(0xFFF44336); // Rojo
    }
  }

  int get priority {
    switch (this) {
      case RiskLevelType.veryLow:
        return 0;
      case RiskLevelType.low:
        return 1;
      case RiskLevelType.moderate:
        return 2;
      case RiskLevelType.high:
        return 3;
      case RiskLevelType.veryHigh:
        return 4;
      case RiskLevelType.extreme:
        return 5;
    }
  }
}