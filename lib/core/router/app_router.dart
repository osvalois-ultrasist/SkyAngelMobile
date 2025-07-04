import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/guards/auth_guard.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/app/presentation/pages/app_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/alertas/presentation/pages/alerts_page.dart';
import '../../features/alertas/presentation/pages/create_alert_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashPage(),
        ),
      ),
      
      // Onboarding route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => const MaterialPage(
          child: OnboardingPage(),
        ),
      ),
      
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
        redirect: (context, state) => AuthGuard.redirectLogic(context, state),
        routes: [
          GoRoute(
            path: 'home',
            name: 'home',
            pageBuilder: (context, state) => const MaterialPage(
              child: AppPage(),
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
          
          // Alert-specific routes (for create and detail pages)
          GoRoute(
            path: 'alerts',
            redirect: (_, __) => '/sky/home', // Redirect to main app
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-alert',
                pageBuilder: (context, state) => const MaterialPage(
                  child: CreateAlertPage(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'alert-detail',
                pageBuilder: (context, state) {
                  final alertId = int.tryParse(state.pathParameters['id'] ?? '');
                  if (alertId == null) {
                    return MaterialPage(
                      child: Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              const Text('ID de alerta inválido'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context.go('/sky/alerts'),
                                child: const Text('Volver a alertas'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  // TODO: Implement AlertDetailPage
                  return MaterialPage(
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text('Alerta #$alertId'),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info, size: 64, color: Colors.blue),
                            const SizedBox(height: 16),
                            Text('Detalle de alerta #$alertId'),
                            const SizedBox(height: 8),
                            const Text('Página en desarrollo'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/sky/alerts'),
                              child: const Text('Volver a alertas'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
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