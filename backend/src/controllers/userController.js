const bcrypt = require('bcryptjs');
const userRepository = require('../repositories/userRepository');
const professionalRepository = require('../repositories/professionalRepository');

class UserController {
  async getProfile(req, res) {
    try {
      const userId = req.user.userId;
      const user = await userRepository.findById(userId);
      
      if (!user) {
        return res.status(404).json({ 
          success: false, 
          error: 'Usuário não encontrado' 
        });
      }

      let professional = null;
      if (user.userType === 'profissional') {
        professional = await professionalRepository.findByUserId(userId);
      }

      res.json({
        success: true,
        user: {
          id: user._id.toString(),
          name: user.name || '',
          email: user.email || '',
          phone: user.phone || '',
          cpf: user.cpf || '',
          birthDate: user.birthDate || '',
          gender: user.gender || '',
          userType: user.userType || '',
          profileImage: user.profileImage || null,
          address: user.address || null,
          bankData: user.bankData || null,
        },
        professional,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar perfil: ' + error.message 
      });
    }
  }

  async updateProfile(req, res) {
    try {
      const userId = req.user.userId;
      const updates = req.body;

      const updatedUser = await userRepository.update(userId, updates);
      
      if (!updatedUser) {
        return res.status(404).json({ 
          success: false, 
          error: 'Usuário não encontrado' 
        });
      }

      res.json({
        success: true,
        user: {
          id: updatedUser._id.toString(),
          name: updatedUser.name || '',
          email: updatedUser.email || '',
          phone: updatedUser.phone || '',
          cpf: updatedUser.cpf || '',
          birthDate: updatedUser.birthDate || '',
          gender: updatedUser.gender || '',
          profileImage: updatedUser.profileImage || null,
          address: updatedUser.address || null,
          bankData: updatedUser.bankData || null,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao atualizar perfil: ' + error.message 
      });
    }
  }

  async changePassword(req, res) {
    try {
      const userId = req.user.userId;
      const { currentPassword, newPassword } = req.body;

      if (!currentPassword || !newPassword) {
        return res.status(400).json({
          success: false,
          error: 'Senha atual e nova senha são obrigatórias',
        });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({
          success: false,
          error: 'A nova senha deve ter pelo menos 6 caracteres',
        });
      }

      const user = await userRepository.findById(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Usuário não encontrado',
        });
      }

      const isValidPassword = await bcrypt.compare(currentPassword, user.password);
      
      if (!isValidPassword) {
        return res.status(401).json({
          success: false,
          error: 'Senha atual incorreta',
        });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);
      await userRepository.update(userId, {
        password: hashedPassword,
      });

      res.json({
        success: true,
        message: 'Senha alterada com sucesso',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao alterar senha: ' + error.message,
      });
    }
  }

  async deleteAccount(req, res) {
    try {
      const userId = req.user.userId;
      const user = await userRepository.findById(userId);

      if (!user) {
        return res.status(404).json({ 
          success: false, 
          error: 'Usuário não encontrado' 
        });
      }

      if (user.userType === 'profissional') {
        await professionalRepository.deleteByUserId(userId);
      }

      await userRepository.delete(userId);

      res.json({
        success: true,
        message: 'Conta deletada com sucesso',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao deletar conta: ' + error.message 
      });
    }
  }
}

module.exports = new UserController();


