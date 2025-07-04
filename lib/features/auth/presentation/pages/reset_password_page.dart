import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_visibility_toggle.dart';

class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    final emailController = useTextEditingController();
    final codeController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final codeFormKey = useMemoized(() => GlobalKey<FormState>());
    final showPassword = useState(false);
    final showConfirmPassword = useState(false);
    final showCodeInput = useState(false);

    Future<void> handleSendCode() async {
      if (formKey.currentState!.validate()) {
        await authNotifier.requestPasswordReset(emailController.text);
        
        if (authState.error == null) {
          showCodeInput.value = true;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código enviado al email'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    }

    Future<void> handleChangePassword() async {
      if (codeFormKey.currentState!.validate()) {
        final success = await authNotifier.confirmPasswordReset(
          username: emailController.text,
          code: codeController.text,
          newPassword: passwordController.text,
        );

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña cambiada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/auth/login');
        }
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
                    child: _buildResetPasswordForm(
                      context: context,
                      authState: authState,
                      formKey: formKey,
                      codeFormKey: codeFormKey,
                      emailController: emailController,
                      codeController: codeController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      showPassword: showPassword,
                      showConfirmPassword: showConfirmPassword,
                      showCodeInput: showCodeInput,
                      handleSendCode: handleSendCode,
                      handleChangePassword: handleChangePassword,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: _buildResetPasswordForm(
                context: context,
                authState: authState,
                formKey: formKey,
                codeFormKey: codeFormKey,
                emailController: emailController,
                codeController: codeController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                showPassword: showPassword,
                showConfirmPassword: showConfirmPassword,
                showCodeInput: showCodeInput,
                handleSendCode: handleSendCode,
                handleChangePassword: handleChangePassword,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm({
    required BuildContext context,
    required AuthState authState,
    required GlobalKey<FormState> formKey,
    required GlobalKey<FormState> codeFormKey,
    required TextEditingController emailController,
    required TextEditingController codeController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required ValueNotifier<bool> showPassword,
    required ValueNotifier<bool> showConfirmPassword,
    required ValueNotifier<bool> showCodeInput,
    required Future<void> Function() handleSendCode,
    required Future<void> Function() handleChangePassword,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text.rich(
                    TextSpan(
                      text: '¿Desear volver al inicio de sesión? ',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Iniciar sesión.',
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
                'Recuperar contraseña',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (!showCodeInput.value) ...[
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Email',
                        placeholder: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: AuthValidators.emailValidator,
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        text: 'Recuperar contraseña',
                        onPressed: handleSendCode,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Form(
                  key: codeFormKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'Código',
                        placeholder: 'Código',
                        controller: codeController,
                        validator: AuthValidators.codeValidator,
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        label: 'Nueva contraseña',
                        placeholder: 'Contraseña',
                        controller: passwordController,
                        obscureText: !showPassword.value,
                        validator: AuthValidators.passwordValidator,
                        suffixIcon: PasswordVisibilityToggle(
                          isVisible: showPassword.value,
                          onToggle: () => showPassword.value = !showPassword.value,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AuthTextField(
                        label: 'Confirmar contraseña',
                        placeholder: 'Confirmar contraseña',
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword.value,
                        validator: (value) => AuthValidators.confirmPasswordValidator(
                          value,
                          passwordController.text,
                        ),
                        suffixIcon: PasswordVisibilityToggle(
                          isVisible: showConfirmPassword.value,
                          onToggle: () =>
                              showConfirmPassword.value = !showConfirmPassword.value,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthButton(
                        text: 'Cambiar contraseña',
                        onPressed: handleChangePassword,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
              ],
              if (authState.error != null) ...[
                const SizedBox(height: 16),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}