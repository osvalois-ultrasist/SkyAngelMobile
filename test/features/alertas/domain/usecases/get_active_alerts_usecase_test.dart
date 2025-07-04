import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:skyangel_mobile/core/error/app_error.dart';
import 'package:skyangel_mobile/core/usecases/usecase.dart';
import 'package:skyangel_mobile/features/alertas/domain/entities/alert_entity.dart';
import 'package:skyangel_mobile/features/alertas/domain/repositories/alert_repository.dart';
import 'package:skyangel_mobile/features/alertas/domain/usecases/get_active_alerts_usecase.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late GetActiveAlertsUseCase useCase;
  late MockAlertRepository mockRepository;

  setUp(() {
    mockRepository = MockAlertRepository();
    useCase = GetActiveAlertsUseCase(mockRepository);
  });

  group('GetActiveAlertsUseCase', () {
    final testAlerts = [
      const AlertEntity(
        id: 1,
        tipo: AlertType.robo,
        incidencia: 'Robo a transeúnte',
        coordenadas: AlertCoordinates(lat: 19.432608, lng: -99.133209),
        comentario: 'Test comment 1',
        fecha: null,
        activa: true,
        usuarioId: 1,
        uuid: 'test-uuid-1',
        prioridad: AlertPriority.alta,
        estado: AlertStatus.activa,
      ),
      const AlertEntity(
        id: 2,
        tipo: AlertType.accidente,
        incidencia: 'Accidente vehicular',
        coordenadas: AlertCoordinates(lat: 19.428472, lng: -99.125858),
        comentario: 'Test comment 2',
        fecha: null,
        activa: true,
        usuarioId: 2,
        uuid: 'test-uuid-2',
        prioridad: AlertPriority.media,
        estado: AlertStatus.activa,
      ),
    ];

    test('should get active alerts successfully when repository returns success', () async {
      // Arrange
      when(() => mockRepository.getActiveAlerts())
          .thenAnswer((_) async => Right(testAlerts));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Right(testAlerts));
      verify(() => mockRepository.getActiveAlerts()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no active alerts exist', () async {
      // Arrange
      when(() => mockRepository.getActiveAlerts())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Right(<AlertEntity>[])); 
      verify(() => mockRepository.getActiveAlerts()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AppError when repository returns failure', () async {
      // Arrange
      const error = AppError.network(
        message: 'Network error',
        details: 'Failed to fetch alerts',
      );
      when(() => mockRepository.getActiveAlerts())
          .thenAnswer((_) async => const Left(error));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, const Left(error));
      verify(() => mockRepository.getActiveAlerts()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle unexpected errors and return unknown error', () async {
      // Arrange
      when(() => mockRepository.getActiveAlerts())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.type, AppErrorType.unknown),
        (r) => fail('Should return unknown error'),
      );
    });
  });
}
