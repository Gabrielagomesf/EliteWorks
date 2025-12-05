import 'package:url_launcher/url_launcher.dart';

class EmailLauncher {
  /// Abre o cliente de email padrão com o email especificado
  /// 
  /// [email] - Email de destino
  /// [subject] - Assunto do email (opcional)
  /// [body] - Corpo do email (opcional)
  static Future<bool> launchEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(emailUri);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Abre um link/URL externa
  static Future<bool> launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

