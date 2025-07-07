import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../utils/auth_validators.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final showPassword = useState(false);
    
    // Animations
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );
    
    final fadeAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ),
      ),
    );
    
    final slideAnimation = useAnimation(
      Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
        ),
      ),
    );

    useEffect(() {
      animationController.forward();
      if (authState.isAuthenticated) {
        context.go('/sky/home');
      }
      return null;
    }, [authState.isAuthenticated]);

    Future<void> handleLogin() async {
      if (formKey.currentState!.validate()) {
        await authNotifier.signIn(
          username: usernameController.text,
          password: passwordController.text,
        );
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 1200;
              final isTablet = constraints.maxWidth > 768;
              
              if (isDesktop) {
                return Row(
                  children: [
                    // Left side - Branding
                    Expanded(
                      flex: 5,
                      child: _buildBrandingSection(
                        context,
                        fadeAnimation,
                        colorScheme,
                      ),
                    ),
                    // Right side - Login Form
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: colorScheme.surface,
                        child: _buildLoginForm(
                          context: context,
                          authState: authState,
                          formKey: formKey,
                          usernameController: usernameController,
                          passwordController: passwordController,
                          showPassword: showPassword,
                          handleLogin: handleLogin,
                          slideAnimation: slideAnimation,
                          fadeAnimation: fadeAnimation,
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              // Mobile/Tablet layout
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.35,
                      child: _buildBrandingSection(
                        context,
                        fadeAnimation,
                        colorScheme,
                        isMobile: true,
                      ),
                    ),
                    _buildLoginForm(
                      context: context,
                      authState: authState,
                      formKey: formKey,
                      usernameController: usernameController,
                      passwordController: passwordController,
                      showPassword: showPassword,
                      handleLogin: handleLogin,
                      slideAnimation: slideAnimation,
                      fadeAnimation: fadeAnimation,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(
    BuildContext context,
    double fadeAnimation,
    ColorScheme colorScheme, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondary,
          ],
        ),
      ),
      child: FadeTransition(
        opacity: AlwaysStoppedAnimation(fadeAnimation),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo con efecto de elevación
                Container(
                  width: isMobile ? 100 : 150,
                  height: isMobile ? 100 : 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.security_outlined,
                    size: isMobile ? 50 : 80,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 40),
                
                // Título
                Text(
                  'SkyAngel',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: isMobile ? 32 : 40,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtítulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Plataforma de análisis de seguridad\ny riesgo para el transporte',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                      fontSize: isMobile ? 16 : 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                if (!isMobile) ...[
                  const SizedBox(height: 48),
                  // Features list para desktop
                  Column(
                    children: [
                      _buildFeatureItem(
                        Icons.map_outlined,
                        'Análisis geoespacial avanzado',
                        Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.analytics_outlined,
                        'Estadísticas en tiempo real',
                        Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        Icons.route_outlined,
                        'Rutas seguras optimizadas',
                        Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm({
    required BuildContext context,
    required AuthState authState,
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required ValueNotifier<bool> showPassword,
    required Future<void> Function() handleLogin,
    required Offset slideAnimation,
    required double fadeAnimation,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: AlwaysStoppedAnimation(fadeAnimation),
      child: SlideTransition(
        position: AlwaysStoppedAnimation(slideAnimation),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width > 768 ? 64 : 32,
            vertical: 48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header con registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bienvenido',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.go('/auth/register'),
                          icon: Icon(
                            Icons.person_add_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          label: Text(
                            'Registrarse',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa a tu cuenta para continuar',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Username field
                    _buildTextField(
                      controller: usernameController,
                      label: 'Usuario',
                      icon: Icons.person_outline,
                      validator: AuthValidators.usernameValidator,
                      colorScheme: colorScheme,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 24),
                    
                    // Password field
                    _buildTextField(
                      controller: passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: !showPassword.value,
                      validator: AuthValidators.passwordValidator,
                      colorScheme: colorScheme,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => handleLogin(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => showPassword.value = !showPassword.value,
                      ),
                    ),
                    
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/auth/reset-password'),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Error message
                    if (authState.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Login button
                    FilledButton.icon(
                      onPressed: authState.isLoading ? null : handleLogin,
                      icon: authState.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        authState.isLoading ? 'Ingresando...' : 'Ingresar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register prompt for mobile
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: '¿No tienes cuenta? ',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          children: [
                            WidgetSpan(
                              child: InkWell(
                                onTap: () => context.go('/auth/register'),
                                child: Text(
                                  'Regístrate aquí',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          icon,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}