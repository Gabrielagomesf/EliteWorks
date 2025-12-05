import 'dart:core';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email';
    }

    value = value.trim().toLowerCase();

    if (value.isEmpty) {
      return 'Por favor, insira seu email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }

    if (value.length > 254) {
      return 'Email muito longo (máximo 254 caracteres)';
    }

    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Por favor, insira ${fieldName ?? 'este campo'}';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return 'Por favor, insira seu nome';
    }

    if (trimmedValue.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres';
    }

    if (trimmedValue.length > 100) {
      return 'O nome deve ter no máximo 100 caracteres';
    }

    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');

    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'O nome deve conter apenas letras e espaços';
    }

    final words = trimmedValue.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length < 2) {
      return 'Por favor, insira seu nome completo';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }

    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    if (value.length > 128) {
      return 'A senha deve ter no máximo 128 caracteres';
    }

    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasUpperCase) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }

    if (!hasLowerCase) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }

    if (!hasNumbers) {
      return 'A senha deve conter pelo menos um número';
    }

    if (!hasSpecialChar) {
      return 'A senha deve conter pelo menos um caractere especial';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu telefone';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) {
      return 'Por favor, insira um telefone válido';
    }

    if (cleaned.length < 10) {
      return 'O telefone deve ter pelo menos 10 dígitos';
    }

    if (cleaned.length > 11) {
      return 'O telefone deve ter no máximo 11 dígitos';
    }

    if (!cleaned.startsWith(RegExp(r'[1-9]'))) {
      return 'O telefone deve começar com um dígito válido';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != originalPassword) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  static String? validateUserType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, selecione um tipo de usuário';
    }

    if (value != 'cliente' && value != 'profissional') {
      return 'Tipo de usuário inválido';
    }

    return null;
  }

  static bool isValidEmail(String emailValue) {
    return email(emailValue) == null;
  }

  static bool isValidPassword(String passwordValue) {
    return password(passwordValue) == null;
  }

  static bool isValidPhone(String phoneValue) {
    return phone(phoneValue) == null;
  }

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Validação básica de CPF (verifica se não são todos iguais)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleaned)) {
      return 'CPF inválido';
    }

    return null;
  }

  static String? cep(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CEP';
    }

    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }

    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Preço é opcional
    }

    final cleaned = value.replaceAll(',', '.');
    final price = double.tryParse(cleaned);

    if (price == null) {
      return 'Por favor, insira um valor válido';
    }

    if (price < 0) {
      return 'O preço não pode ser negativo';
    }

    if (price > 999999.99) {
      return 'O preço não pode ser maior que R\$ 999.999,99';
    }

    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Bio é opcional
    }

    if (value.trim().length > 500) {
      return 'A bio deve ter no máximo 500 caracteres';
    }

    return null;
  }

  static String? coverageArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Área de cobertura é opcional
    }

    if (value.trim().length < 3) {
      return 'A área de cobertura deve ter pelo menos 3 caracteres';
    }

    if (value.trim().length > 100) {
      return 'A área de cobertura deve ter no máximo 100 caracteres';
    }

    return null;
  }

  static String? experience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Experiência é opcional
    }

    if (value.trim().length < 10) {
      return 'A experiência deve ter pelo menos 10 caracteres';
    }

    if (value.trim().length > 1000) {
      return 'A experiência deve ter no máximo 1000 caracteres';
    }

    return null;
  }
}
