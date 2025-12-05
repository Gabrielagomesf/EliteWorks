const nodemailer = require('nodemailer');
require('dotenv').config();

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      auth: {
        user: process.env.GMAIL_USERNAME,
        pass: process.env.GMAIL_APP_PASSWORD,
      },
    });
  }

  async sendPasswordResetEmail(email, token) {
    try {
      const mailOptions = {
        from: process.env.GMAIL_USERNAME,
        to: email,
        subject: 'Recuperação de Senha - EliteWorks',
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <style>
              body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
              }
              .container {
                background-color: #f9f9f9;
                padding: 30px;
                border-radius: 10px;
                text-align: center;
              }
              .token-box {
                background-color: #fff;
                border: 2px solid #4CAF50;
                border-radius: 8px;
                padding: 20px;
                margin: 20px 0;
                font-size: 32px;
                font-weight: bold;
                color: #4CAF50;
                letter-spacing: 5px;
              }
              .footer {
                margin-top: 30px;
                font-size: 12px;
                color: #666;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <h1>Recuperação de Senha</h1>
              <p>Você solicitou a recuperação de senha. Use o código abaixo para redefinir sua senha:</p>
              <div class="token-box">${token}</div>
              <p>Este código expira em 1 hora.</p>
              <p>Se você não solicitou esta recuperação, ignore este email.</p>
              <div class="footer">
                <p>EliteWorks - Conectando profissionais e clientes</p>
              </div>
            </div>
          </body>
          </html>
        `,
      };

      await this.transporter.sendMail(mailOptions);
      return { success: true };
    } catch (error) {
      throw new Error('Erro ao enviar email: ' + error.message);
    }
  }
}

module.exports = new EmailService();


