const PasswordResetToken = require('../models/PasswordResetToken');

class PasswordResetTokenRepository {
  async create(tokenData) {
    try {
      const token = new PasswordResetToken(tokenData);
      return await token.save();
    } catch (error) {
      throw error;
    }
  }

  async findByEmailAndToken(email, token) {
    try {
      return await PasswordResetToken.findOne({
        email: email.toLowerCase(),
        token,
        used: false,
      });
    } catch (error) {
      throw error;
    }
  }

  async markAsUsed(email, token) {
    try {
      return await PasswordResetToken.updateOne(
        { email: email.toLowerCase(), token },
        { $set: { used: true } }
      );
    } catch (error) {
      throw error;
    }
  }

  async deleteExpired() {
    try {
      return await PasswordResetToken.deleteMany({
        expiresAt: { $lt: new Date() },
      });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new PasswordResetTokenRepository();


