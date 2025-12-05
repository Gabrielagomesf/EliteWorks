class AuthValidator {
  static String? validateRegistration({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) {
    if (email.isEmpty) {
      return 'Email é obrigatório';
    }

    if (password.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (name.isEmpty) {
      return 'Nome é obrigatório';
    }

    if (phone.isEmpty) {
      return 'Telefone é obrigatório';
    }

    if (userType.isEmpty) {
      return 'Tipo de usuário é obrigatório';
    }

    return null;
  }

  static String? validateLogin({
    required String email,
    required String password,
  }) {
    if (email.isEmpty) {
      return 'Email é obrigatório';
    }

    if (password.isEmpty) {
      return 'Senha é obrigatória';
    }

    return null;
  }

  static bool isEmailFormatValid(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static bool isPasswordStrong(String password) {
    if (password.length < 8) return false;

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUpperCase && hasLowerCase && hasNumbers && hasSpecialChar;
  }

  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) {
      return 'Digite uma senha';
    }

    if (password.length < 8) {
      return 'Senha fraca: mínimo 8 caracteres';
    }

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasNumbers) strength++;
    if (hasSpecialChar) strength++;

    if (strength <= 2) {
      return 'Senha fraca';
    } else if (strength == 3) {
      return 'Senha média';
    } else {
      return 'Senha forte';
    }
  }
}



