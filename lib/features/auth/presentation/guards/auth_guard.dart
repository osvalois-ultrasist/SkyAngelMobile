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
    final secureStorage = GetIt.I<SecureStorage>();
    final accessToken = await secureStorage.read('access_token');
    
    final isAuth = state.matchedLocation.startsWith('/auth');
    final isAuthenticated = accessToken != null && accessToken.isNotEmpty;

    // Si está autenticado y trata de acceder a páginas de auth, redirigir a home
    if (isAuthenticated && isAuth) {
      return '/sky/home';
    }

    // Si no está autenticado y trata de acceder a páginas protegidas
    if (!isAuthenticated && !isAuth && state.matchedLocation.startsWith('/sky')) {
      return '/auth/login';
    }

    return null;
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