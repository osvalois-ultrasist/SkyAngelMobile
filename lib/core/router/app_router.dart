import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/guards/auth_guard.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/app/presentation/pages/app_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) => AuthGuard.redirectLogic(context, state),
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth',
        redirect: (_, __) => '/auth/login',
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            pageBuilder: (context, state) => const MaterialPage(
              child: LoginPage(),
            ),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            pageBuilder: (context, state) => const MaterialPage(
              child: RegisterPage(),
            ),
          ),
          GoRoute(
            path: 'reset-password',
            name: 'reset-password',
            pageBuilder: (context, state) => const MaterialPage(
              child: ResetPasswordPage(),
            ),
          ),
        ],
      ),
      
      // Protected routes
      GoRoute(
        path: '/sky',
        redirect: (_, __) => '/sky/home',
        routes: [
          GoRoute(
            path: 'home',
            name: 'home',
            pageBuilder: (context, state) => MaterialPage(
              child: AuthAwareWidget(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('SkyAngel - Home'),
                  ),
                  body: const Center(
                    child: Text('Bienvenido a SkyAngel'),
                  ),
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'account',
            name: 'account',
            pageBuilder: (context, state) => MaterialPage(
              child: AuthAwareWidget(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Mi Cuenta'),
                  ),
                  body: const Center(
                    child: Text('Página de cuenta de usuario'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Default route
      GoRoute(
        path: '/',
        redirect: (_, __) => '/auth/login',
      ),
    ],
    
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '404',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Página no encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}