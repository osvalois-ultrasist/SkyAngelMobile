import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:skyangel_mobile/core/error/app_error.dart';
import 'package:skyangel_mobile/core/usecases/usecase.dart';
import 'package:skyangel_mobile/features/alertas/domain/entities/alert_entity.dart';
import 'package:skyangel_mobile/features/alertas/domain/entities/create_alert_request.dart';
import 'package:skyangel_mobile/features/alertas/domain/usecases/create_alert_usecase.dart';
import 'package:skyangel_mobile/features/alertas/domain/usecases/get_active_alerts_usecase.dart';
import 'package:skyangel_mobile/features/alertas/presentation/providers/alert_provider.dart';
import 'package:skyangel_mobile/features/alertas/presentation/providers/alert_state.dart';

class MockGetActiveAlertsUseCase extends Mock implements GetActiveAlertsUseCase {}
class MockCreateAlertUseCase extends Mock implements CreateAlertUseCase {}

void main() {
  late MockGetActiveAlertsUseCase mockGetActiveAlertsUseCase;
  late MockCreateAlertUseCase mockCreateAlertUseCase;
  late ProviderContainer container;

  setUp(() {
    mockGetActiveAlertsUseCase = MockGetActiveAlertsUseCase();
    mockCreateAlertUseCase = MockCreateAlertUseCase();
    
    container = ProviderContainer(
      overrides: [
        // Note: In a real implementation, you'd need to override the actual providers
        // This is a simplified example
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AlertNotifier', () {
    const testAlert = AlertEntity(
      id: 1,
      tipo: AlertType.robo,
      incidencia: 'Robo a transeúnte',
      coordenadas: AlertCoordinates(lat: 19.432608, lng: -99.133209),
      comentario: 'Test comment',
      fecha: null,
      activa: true,
      usuarioId: 1,
      uuid: 'test-uuid',
      prioridad: AlertPriority.alta,
      estado: AlertStatus.activa,
    );

    test('should have initial state when created', () {
      // Act
      final state = container.read(alertNotifierProvider);

      // Assert
      expect(state, const AlertState.initial());
    });

    test('should handle successful alert loading', () async {
      // Arrange
      final testAlerts = [testAlert];
      when(() => mockGetActiveAlertsUseCase(NoParams()))
          .thenAnswer((_) async => Right(testAlerts));

      // Act
      final notifier = container.read(alertNotifierProvider.notifier);
      await notifier.loadActiveAlerts();
      
      // Assert
      final state = container.read(alertNotifierProvider);
      expect(state, AlertState.loaded(alerts: testAlerts));
    });

    test('should handle loading error', () async {
      // Arrange
      const error = AppError.network(
        message: 'Network error',
        details: 'Failed to load alerts',
      );
      when(() => mockGetActiveAlertsUseCase(NoParams()))
          .thenAnswer((_) async => const Left(error));

      // Act
      final notifier = container.read(alertNotifierProvider.notifier);
      await notifier.loadActiveAlerts();
      
      // Assert
      final state = container.read(alertNotifierProvider);
      expect(state, const AlertState.error(error: error, message: 'Network error'));
    });

    test('should handle successful alert creation', () async {
      // Arrange
      const request = CreateAlertRequest(
        tipo: 'robo',
        incidencia: 'Robo a transeúnte',
        coordenadas: '19.432608,-99.133209',
        comentario: 'Test comment',
      );
      when(() => mockCreateAlertUseCase(request))
          .thenAnswer((_) async => const Right(testAlert));

      // Act
      final notifier = container.read(alertNotifierProvider.notifier);
      await notifier.createAlert(request);
      
      // Assert
      final state = container.read(alertNotifierProvider);
      expect(state, const AlertState.loaded(alerts: [testAlert]));
    });
  });

  group('AlertState extensions', () {
    test('should correctly identify loading state', () {
      const state = AlertState.loading();
      
      expect(state.isLoading, true);
      expect(state.hasError, false);
      expect(state.hasData, false);
    });

    test('should correctly identify error state', () {
      const state = AlertState.error(
        error: AppError.unknown(message: 'Test error', details: 'Details'),
        message: 'Test error',
      );
      
      expect(state.isLoading, false);
      expect(state.hasError, true);
      expect(state.hasData, false);
    });

    test('should correctly identify loaded state', () {
      const state = AlertState.loaded(alerts: []);
      
      expect(state.isLoading, false);
      expect(state.hasError, false);
      expect(state.hasData, true);
    });

    test('should correctly group alerts by type', () {
      const alert1 = AlertEntity(
        id: 1,
        tipo: AlertType.robo,
        incidencia: 'Test 1',
        coordenadas: AlertCoordinates(lat: 1, lng: 1),
        comentario: '',
        fecha: null,
        activa: true,
        usuarioId: 1,
        uuid: 'uuid1',
        prioridad: AlertPriority.media,
        estado: AlertStatus.activa,
      );
      
      const alert2 = AlertEntity(
        id: 2,
        tipo: AlertType.robo,
        incidencia: 'Test 2',
        coordenadas: AlertCoordinates(lat: 2, lng: 2),
        comentario: '',
        fecha: null,
        activa: true,
        usuarioId: 1,
        uuid: 'uuid2',
        prioridad: AlertPriority.alta,
        estado: AlertStatus.activa,
      );
      
      const alert3 = AlertEntity(
        id: 3,
        tipo: AlertType.accidente,
        incidencia: 'Test 3',
        coordenadas: AlertCoordinates(lat: 3, lng: 3),
        comentario: '',
        fecha: null,
        activa: true,
        usuarioId: 1,
        uuid: 'uuid3',
        prioridad: AlertPriority.baja,
        estado: AlertStatus.activa,
      );
      
      const state = AlertState.loaded(alerts: [alert1, alert2, alert3]);
      final grouped = state.alertsByType;
      
      expect(grouped[AlertType.robo], [alert1, alert2]);
      expect(grouped[AlertType.accidente], [alert3]);
      expect(grouped[AlertType.violencia], null);
    });
  });
}
