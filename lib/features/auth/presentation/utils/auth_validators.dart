class AuthValidators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email es requerido.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email no válido.';
    }

    return null;
  }

  static String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Usuario es requerido.';
    }

    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[\W_]).{8,}$');
    
    if (!passwordRegex.hasMatch(value)) {
      return 'Debe tener al menos 8 caracteres, una mayúscula y un símbolo.';
    }

    return null;
  }

  static String? confirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmación requerida.';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre es requerido.';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }

    return null;
  }

  static String? lastNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Apellidos es requerido.';
    }

    if (value.length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres.';
    }

    return null;
  }

  static String? codeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Código es requerido.';
    }

    if (value.length < 6) {
      return 'El código debe tener al menos 6 caracteres.';
    }

    return null;
  }
}