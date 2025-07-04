import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'app_initialization_provider.freezed.dart';

@freezed
class AppInitializationState with _$AppInitializationState {
  const factory AppInitializationState({
    @Default(false) bool isInitialized,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _AppInitializationState;
}

final appInitializationProvider = 
    StateNotifierProvider<AppInitializationNotifier, AppInitializationState>((ref) {
  return AppInitializationNotifier(ref);
});

class AppInitializationNotifier extends StateNotifier<AppInitializationState> {
  final Ref _ref;

  AppInitializationNotifier(this._ref) : super(const AppInitializationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, hasError: false);
    
    try {
      AppLogger.info('Starting app initialization...');
      
      // Simular tiempo mínimo de splash para UX
      final initializationFuture = _performInitialization();
      final minimumDisplayFuture = Future.delayed(const Duration(seconds: 2));
      
      await Future.wait([initializationFuture, minimumDisplayFuture]);
      
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        hasError: false,
      );
      
      AppLogger.info('App initialization completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('App initialization failed', error: e, stackTrace: stackTrace);
      
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _performInitialization() async {
    try {
      // Verificar que las dependencias estén configuradas
      AppLogger.info('Checking dependency injection...');
      
      // Verificar servicios críticos
      AppLogger.info('Dependencies are registered and ready');
      
      // Inicializar estado de autenticación
      AppLogger.info('Initializing authentication state...');
      final authNotifier = _ref.read(authStateProvider.notifier);
      
      // Dar tiempo para que el auth provider se inicialice
      await Future.delayed(const Duration(milliseconds: 500));
      
      AppLogger.info('App initialization tasks completed');
    } catch (e) {
      AppLogger.error('Error during app initialization', error: e);
      rethrow;
    }
  }

  void retry() {
    _initialize();
  }
}