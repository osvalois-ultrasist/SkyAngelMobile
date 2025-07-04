import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';
import 'package:get_it/get_it.dart';

class AuthGuard {
  static Future<String?> redirectLogic(
    BuildContext context,
    GoRouterState state,
  ) async {
    try {
      // No redirigir desde splash
      if (state.matchedLocation == '/splash') {
        return null;
      }
      
      // Verificar si GetIt está listo
      if (!GetIt.I.isRegistered<SecureStorage>()) {
        // Si aún no está listo, redirigir a splash
        return '/splash';
      }
      
      final secureStorage = GetIt.I<SecureStorage>();
      final accessToken = await secureStorage.read('access_token');
      
      final isAuth = state.matchedLocation.startsWith('/auth');
      final isProtected = state.matchedLocation.startsWith('/sky');
      final isAuthenticated = accessToken != null && accessToken.isNotEmpty;

      // Si está autenticado y trata de acceder a páginas de auth, redirigir a home
      if (isAuthenticated && isAuth) {
        return '/sky/home';
      }

      // Si no está autenticado y trata de acceder a páginas protegidas
      if (!isAuthenticated && isProtected) {
        return '/auth/login';
      }

      return null;
    } catch (e) {
      // En caso de error, redirigir a splash para reinicializar
      return '/splash';
    }
  }
}

class AuthAwareWidget extends ConsumerWidget {
  final Widget child;

  const AuthAwareWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Si no está autenticado, redirigir a login
    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/auth/login');
      });
    }

    return child;
  }
}