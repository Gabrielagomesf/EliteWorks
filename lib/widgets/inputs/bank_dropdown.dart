import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class BankDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final String? Function(String?)? validator;

  const BankDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.validator,
  });

  static const List<Map<String, String>> banks = [
    {'code': '001', 'name': 'Banco do Brasil'},
    {'code': '033', 'name': 'Banco Santander'},
    {'code': '104', 'name': 'Caixa Econômica Federal'},
    {'code': '237', 'name': 'Banco Bradesco'},
    {'code': '341', 'name': 'Banco Itaú'},
    {'code': '356', 'name': 'Banco Real'},
    {'code': '422', 'name': 'Banco Safra'},
    {'code': '748', 'name': 'Banco Cooperativo Sicredi'},
    {'code': '756', 'name': 'Bancoob'},
    {'code': '260', 'name': 'Nu Pagamentos (Nubank)'},
    {'code': '290', 'name': 'PagBank'},
    {'code': '323', 'name': 'Mercado Pago'},
    {'code': '077', 'name': 'Banco Inter'},
    {'code': '212', 'name': 'Banco Original'},
    {'code': '655', 'name': 'Banco Votorantim'},
    {'code': '070', 'name': 'Banco de Brasília'},
    {'code': '041', 'name': 'Banco Banrisul'},
    {'code': '085', 'name': 'Cooperativa Central de Crédito'},
    {'code': '125', 'name': 'Brasil Plural'},
    {'code': '184', 'name': 'Banco Itaú BBA'},
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: 'Banco',
        prefixIcon: const Icon(Icons.account_balance_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: AppColors.background,
        enabled: enabled,
      ),
      items: banks.map((bank) {
        return DropdownMenuItem<String>(
          value: bank['code'],
          child: Text(
            '${bank['code']} - ${bank['name']}',
            style: GoogleFonts.inter(),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: GoogleFonts.inter(),
    );
  }
}

