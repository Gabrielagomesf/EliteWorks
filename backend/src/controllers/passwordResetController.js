const bcrypt = require('bcryptjs');
const userRepository = require('../repositories/userRepository');
const passwordResetTokenRepository = require('../repositories/passwordResetTokenRepository');
const emailService = require('../services/emailService');

class PasswordResetController {
  async requestReset(req, res) {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({
          success: false,
          error: 'Email é obrigatório',
        });
      }

      const user = await userRepository.findByEmail(email);
      
      if (!user) {
        return res.json({
          success: true,
          message: 'Se o email estiver cadastrado, você receberá um código de recuperação',
        });
      }

      const token = this._generateResetToken();
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 1);

      await passwordResetTokenRepository.create({
        email: email.toLowerCase(),
        token,
        userId: user._id.toString(),
        expiresAt,
        used: false,
      });

      await emailService.sendPasswordResetEmail(email, token);

      res.json({
        success: true,
        message: 'Código de recuperação enviado por email',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao solicitar recuperação de senha: ' + error.message,
      });
    }
  }

  async validateToken(req, res) {
    try {
      const { token, email } = req.body;

      if (!token || !email) {
        return res.status(400).json({
          success: false,
          error: 'Token e email são obrigatórios',
        });
      }

      const resetToken = await passwordResetTokenRepository.findByEmailAndToken(
        email.toLowerCase(),
        token
      );

      if (!resetToken) {
        return res.json({
          valid: false,
          error: 'Token inválido ou já utilizado',
        });
      }

      if (new Date(resetToken.expiresAt) < new Date()) {
        return res.json({
          valid: false,
          error: 'Token expirado. Solicite uma nova recuperação de senha',
        });
      }

      res.json({
        valid: true,
        userId: resetToken.userId,
      });
    } catch (error) {
      res.status(500).json({
        valid: false,
        error: 'Erro ao validar token: ' + error.message,
      });
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, email, newPassword } = req.body;

      if (!token || !email || !newPassword) {
        return res.status(400).json({
          success: false,
          error: 'Token, email e nova senha são obrigatórios',
        });
      }

      const resetToken = await passwordResetTokenRepository.findByEmailAndToken(
        email.toLowerCase(),
        token
      );

      if (!resetToken) {
        return res.status(400).json({
          success: false,
          error: 'Token inválido ou já utilizado',
        });
      }

      if (new Date(resetToken.expiresAt) < new Date()) {
        return res.status(400).json({
          success: false,
          error: 'Token expirado. Solicite uma nova recuperação de senha',
        });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);
      await userRepository.update(resetToken.userId, {
        password: hashedPassword,
      });

      await passwordResetTokenRepository.markAsUsed(email.toLowerCase(), token);

      res.json({
        success: true,
        message: 'Senha redefinida com sucesso',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao redefinir senha: ' + error.message,
      });
    }
  }

  _generateResetToken() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}

module.exports = new PasswordResetController();


