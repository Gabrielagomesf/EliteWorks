import 'package:intl/intl.dart';

/// Utilitário para formatação de textos, moedas, datas, etc.
class Formatters {
  /// Formata valor monetário em Real (R$)
  static String currency(double? value, {bool showSymbol = true}) {
    if (value == null) return showSymbol ? 'R\$ 0,00' : '0,00';
    
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: showSymbol ? 'R\$ ' : '',
      decimalDigits: 2,
    );
    
    return formatter.format(value);
  }

  /// Formata telefone brasileiro
  static String phone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    
    // Remove tudo que não é número
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10) {
      // (XX) XXXX-XXXX
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11) {
      // (XX) 9XXXX-XXXX
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    }
    
    return phone; // Retorna original se não conseguir formatar
  }

  /// Formata CPF
  static String cpf(String? cpf) {
    if (cpf == null || cpf.isEmpty) return '';
    
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    }
    
    return cpf;
  }

  /// Formata CEP
  static String cep(String? cep) {
    if (cep == null || cep.isEmpty) return '';
    
    final cleaned = cep.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    }
    
    return cep;
  }

  /// Formata data completa (dd/MM/yyyy HH:mm)
  static String dateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formata data (dd/MM/yyyy)
  static String date(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formata hora (HH:mm)
  static String time(DateTime? date) {
    if (date == null) return '';
    return DateFormat('HH:mm').format(date);
  }

  /// Formata data relativa (Hoje, Ontem, X dias atrás)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 semana atrás' : '$weeks semanas atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 mês atrás' : '$months meses atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Limita texto com ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Formata número com separador de milhar
  static String number(int? value) {
    if (value == null) return '0';
    return NumberFormat('#,##0').format(value);
  }

  /// Formata porcentagem
  static String percentage(double? value) {
    if (value == null) return '0%';
    return '${value.toStringAsFixed(0)}%';
  }

  /// Capitaliza primeira letra de cada palavra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Remove acentos
  static String removeAccents(String text) {
    const accents = 'áàâãéèêíìîóòôõúùûçÁÀÂÃÉÈÊÍÌÎÓÒÔÕÚÙÛÇ';
    const withoutAccents = 'aaaaeeeiiioooouuucAAAAEEEIIIOOOOUUUC';
    
    String result = text;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }
}

