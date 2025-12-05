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
          name: user.name,
          email: user.email,
          phone: user.phone,
          cpf: user.cpf,
          birthDate: user.birthDate,
          gender: user.gender,
          userType: user.userType,
          profileImage: user.profileImage,
          address: user.address,
          bankData: user.bankData,
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
          name: updatedUser.name,
          email: updatedUser.email,
          phone: updatedUser.phone,
          cpf: updatedUser.cpf,
          birthDate: updatedUser.birthDate,
          gender: updatedUser.gender,
          profileImage: updatedUser.profileImage,
          address: updatedUser.address,
          bankData: updatedUser.bankData,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao atualizar perfil: ' + error.message 
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


