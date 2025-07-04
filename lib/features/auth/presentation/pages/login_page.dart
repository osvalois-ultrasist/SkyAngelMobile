import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_visibility_toggle.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final showPassword = useState(false);

    useEffect(() {
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
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: const Center(
                        child: Image(
                          image: AssetImage('assets/images/img_login_skyangel.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildLoginForm(
                      context: context,
                      authState: authState,
                      formKey: formKey,
                      usernameController: usernameController,
                      passwordController: passwordController,
                      showPassword: showPassword,
                      handleLogin: handleLogin,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: _buildLoginForm(
                context: context,
                authState: authState,
                formKey: formKey,
                usernameController: usernameController,
                passwordController: passwordController,
                showPassword: showPassword,
                handleLogin: handleLogin,
              ),
            );
          },
        ),
      ),
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
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/auth/register'),
                    child: Text.rich(
                      TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Regístrate',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Plataforma de riesgo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  label: 'Usuario',
                  placeholder: 'Usuario',
                  controller: usernameController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidators.usernameValidator,
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Contraseña',
                  placeholder: 'Contraseña',
                  controller: passwordController,
                  obscureText: !showPassword.value,
                  validator: AuthValidators.passwordValidator,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: showPassword.value,
                    onToggle: () => showPassword.value = !showPassword.value,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/auth/reset-password'),
                    child: Text(
                      'Olvidó su contraseña. Recupérala aquí.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      authState.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AuthButton(
                  text: 'Ingresar',
                  onPressed: handleLogin,
                  isLoading: authState.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}