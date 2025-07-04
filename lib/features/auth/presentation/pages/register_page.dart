import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_visibility_toggle.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    final nameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final verificationCodeController = useTextEditingController();
    
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final showPassword = useState(false);
    final showConfirmPassword = useState(false);
    final showVerificationStep = useState(false);

    Future<void> handleSignUp() async {
      if (formKey.currentState!.validate()) {
        await authNotifier.signUp(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          familyName: lastNameController.text,
        );

        if (authState.error == null) {
          showVerificationStep.value = true;
        }
      }
    }

    Future<void> handleVerification() async {
      final success = await authNotifier.confirmUser(
        username: emailController.text,
        code: verificationCodeController.text,
      );

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código de verificación correcto'),
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
                    child: _buildRegisterForm(
                      context: context,
                      authState: authState,
                      formKey: formKey,
                      nameController: nameController,
                      lastNameController: lastNameController,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      verificationCodeController: verificationCodeController,
                      showPassword: showPassword,
                      showConfirmPassword: showConfirmPassword,
                      showVerificationStep: showVerificationStep,
                      handleSignUp: handleSignUp,
                      handleVerification: handleVerification,
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: _buildRegisterForm(
                context: context,
                authState: authState,
                formKey: formKey,
                nameController: nameController,
                lastNameController: lastNameController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                verificationCodeController: verificationCodeController,
                showPassword: showPassword,
                showConfirmPassword: showConfirmPassword,
                showVerificationStep: showVerificationStep,
                handleSignUp: handleSignUp,
                handleVerification: handleVerification,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegisterForm({
    required BuildContext context,
    required AuthState authState,
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController lastNameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController verificationCodeController,
    required ValueNotifier<bool> showPassword,
    required ValueNotifier<bool> showConfirmPassword,
    required ValueNotifier<bool> showVerificationStep,
    required Future<void> Function() handleSignUp,
    required Future<void> Function() handleVerification,
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
                Text(
                  'Registro de usuario',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!showVerificationStep.value) ...[
                  AuthTextField(
                    label: 'Nombre',
                    placeholder: 'Nombre',
                    controller: nameController,
                    validator: AuthValidators.nameValidator,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'Apellidos',
                    placeholder: 'Apellidos',
                    controller: lastNameController,
                    validator: AuthValidators.lastNameValidator,
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'Email',
                    placeholder: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.emailValidator,
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
                ] else ...[
                  AuthTextField(
                    label: 'Código de verificación',
                    placeholder: 'Código de verificación',
                    controller: verificationCodeController,
                    validator: AuthValidators.codeValidator,
                  ),
                ],
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
                  text: showVerificationStep.value ? 'Verificar' : 'Registrar',
                  onPressed:
                      showVerificationStep.value ? handleVerification : handleSignUp,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text.rich(
                    TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
    );
  }
}