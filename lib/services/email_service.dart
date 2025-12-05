import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static String? _smtpUsername;
  static String? _smtpPassword;
  static bool _initialized = false;

  /// Inicializa o serviço de email com credenciais do .env
  static Future<void> initialize() async {
    if (_initialized) return;

    await dotenv.load(fileName: ".env");
    _smtpUsername = dotenv.env['GMAIL_USERNAME'];
    _smtpPassword = dotenv.env['GMAIL_APP_PASSWORD'];

    if (_smtpUsername == null || _smtpPassword == null) {
      throw Exception(
        'Gmail credentials não encontradas no .env. '
        'Adicione GMAIL_USERNAME e GMAIL_APP_PASSWORD',
      );
    }

    _initialized = true;
  }

  /// Envia email de recuperação de senha
  /// 
  /// [toEmail] - Email de destino
  /// [userName] - Nome do usuário
  /// [resetToken] - Token de recuperação
  /// [resetUrl] - URL para resetar senha (opcional, se não fornecido usa deep link)
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String toEmail,
    required String userName,
    required String resetToken,
    String? resetUrl,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      if (_smtpUsername == null || _smtpPassword == null) {
        return {
          'success': false,
          'error': 'Credenciais de email não configuradas',
        };
      }

      // Configurar servidor SMTP do Gmail
      final smtpServer = gmail(_smtpUsername!, _smtpPassword!);

      // Criar mensagem
      final message = Message()
        ..from = Address(_smtpUsername!, 'EliteWorks')
        ..recipients.add(toEmail)
        ..subject = 'Recuperação de Senha - EliteWorks'
        ..html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
              color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
    .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
    .button { display: inline-block; padding: 12px 30px; background: #667eea; 
              color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
    .token-box { background: #fff; padding: 15px; border-left: 4px solid #667eea; 
                 margin: 20px 0; font-family: monospace; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔐 Recuperação de Senha</h1>
    </div>
    <div class="content">
      <p>Olá <strong>$userName</strong>,</p>
      <p>Recebemos uma solicitação para redefinir a senha da sua conta no EliteWorks.</p>
      <p>Use o código abaixo no app para redefinir sua senha:</p>
      <div class="token-box" style="text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 8px; padding: 20px;">
        $resetToken
      </div>
      <p style="text-align: center; color: #666; font-size: 14px; margin-top: 10px;">
        Digite este código na tela de recuperação de senha do app
      </p>
      <p><strong>Este link expira em 1 hora.</strong></p>
      <p>Se você não solicitou esta recuperação de senha, ignore este email.</p>
      <p>Atenciosamente,<br>Equipe EliteWorks</p>
    </div>
    <div class="footer">
      <p>© 2024 EliteWorks. Todos os direitos reservados.</p>
      <p>Este é um email automático, por favor não responda.</p>
    </div>
  </div>
</body>
</html>
''';

      // Enviar email
      try {
        await send(message, smtpServer);
        
        // Se chegou aqui, o email foi enviado com sucesso
        return {
          'success': true,
          'message': 'Email enviado com sucesso',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Erro ao enviar email: $e',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao enviar email: $e',
      };
    }
  }

  /// Envia email genérico
  static Future<Map<String, dynamic>> sendEmail({
    required String toEmail,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      if (_smtpUsername == null || _smtpPassword == null) {
        return {
          'success': false,
          'error': 'Credenciais de email não configuradas',
        };
      }

      final smtpServer = gmail(_smtpUsername!, _smtpPassword!);

      final message = Message()
        ..from = Address(_smtpUsername!, 'EliteWorks')
        ..recipients.add(toEmail)
        ..subject = subject
        ..text = body;

      if (htmlBody != null) {
        message.html = htmlBody;
      }

      try {
        await send(message, smtpServer);
        
        // Se chegou aqui, o email foi enviado com sucesso
        return {
          'success': true,
          'message': 'Email enviado com sucesso',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Erro ao enviar email: $e',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao enviar email: $e',
      };
    }
  }
}

