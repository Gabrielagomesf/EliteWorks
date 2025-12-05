import 'dart:convert';
import 'package:http/http.dart' as http;

class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  static Future<Map<String, dynamic>?> getAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos
      final cleanCep = cep.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCep.length != 8) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanCep/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se o CEP foi encontrado (não tem erro)
        if (data.containsKey('erro') && data['erro'] == true) {
          return null;
        }

        return {
          'street': data['logradouro'] ?? '',
          'neighborhood': data['bairro'] ?? '',
          'city': data['localidade'] ?? '',
          'state': data['uf'] ?? '',
          'zipCode': cleanCep,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}



