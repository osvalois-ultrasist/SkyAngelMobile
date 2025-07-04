import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:skyangel_mobile/core/error/app_error.dart';
import 'package:skyangel_mobile/features/alertas/domain/entities/alert_entity.dart';
import 'package:skyangel_mobile/features/alertas/domain/entities/create_alert_request.dart';
import 'package:skyangel_mobile/features/alertas/domain/repositories/alert_repository.dart';
import 'package:skyangel_mobile/features/alertas/domain/usecases/create_alert_usecase.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late CreateAlertUseCase useCase;
  late MockAlertRepository mockRepository;

  setUp(() {
    mockRepository = MockAlertRepository();
    useCase = CreateAlertUseCase(mockRepository);
  });

  group('CreateAlertUseCase', () {
    const testRequest = CreateAlertRequest(
      tipo: 'robo',
      incidencia: 'Robo a transeúnte',
      coordenadas: '19.432608,-99.133209',
      comentario: 'Test comment',
    );

    const testAlert = AlertEntity(
      id: 1,
      tipo: AlertType.robo,
      incidencia: 'Robo a transeúnte',
      coordenadas: AlertCoordinates(lat: 19.432608, lng: -99.133209),
      comentario: 'Test comment',
      fecha: null, // Will be set in test
      activa: true,
      usuarioId: 1,
      uuid: 'test-uuid',
      prioridad: AlertPriority.media,
      estado: AlertStatus.activa,
    );

    test('should create alert successfully when repository returns success', () async {
      // Arrange
      when(() => mockRepository.createAlert(testRequest))
          .thenAnswer((_) async => const Right(testAlert));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, const Right(testAlert));
      verify(() => mockRepository.createAlert(testRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AppError when repository returns failure', () async {
      // Arrange
      const error = AppError.network(
        message: 'Network error',
        details: 'Failed to connect',
      );
      when(() => mockRepository.createAlert(testRequest))
          .thenAnswer((_) async => const Left(error));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, const Left(error));
      verify(() => mockRepository.createAlert(testRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return validation error when request is invalid', () async {
      // Arrange
      const invalidRequest = CreateAlertRequest(
        tipo: '',
        incidencia: '',
        coordenadas: 'invalid',
        comentario: '',
      );

      // Act
      final result = await useCase(invalidRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.type, AppErrorType.validation),
        (r) => fail('Should return validation error'),
      );
      verifyNever(() => mockRepository.createAlert(any()));
    });

    test('should handle unexpected errors and return unknown error', () async {
      // Arrange
      when(() => mockRepository.createAlert(testRequest))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.type, AppErrorType.unknown),
        (r) => fail('Should return unknown error'),
      );
    });
  });
}
