const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');
const professionalRepository = require('../repositories/professionalRepository');

class AuthController {
  async register(req, res) {
    try {
      const { email, password, name, phone, userType } = req.body;

      if (!email || !password || !name || !userType) {
        return res.status(400).json({ 
          success: false, 
          error: 'Campos obrigatórios faltando' 
        });
      }

      const existingUser = await userRepository.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({ 
          success: false, 
          error: 'Email já cadastrado' 
        });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      
      const user = await userRepository.create({
        email: email.toLowerCase(),
        password: hashedPassword,
        name,
        phone,
        userType,
      });

      let professional = null;
      if (userType === 'profissional') {
        const { specialty, bio, categories } = req.body;
        professional = await professionalRepository.create({
          userId: user._id,
          specialty: specialty || '',
          bio: bio || '',
          categories: categories || [],
        });
      }

      const token = jwt.sign(
        { userId: user._id.toString(), email: user.email, userType: user.userType },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.status(201).json({
        success: true,
        user: {
          id: user._id.toString(),
          email: user.email,
          name: user.name,
          userType: user.userType,
        },
        professional: professional ? {
          id: professional._id.toString(),
          specialty: professional.specialty,
        } : null,
        token,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao registrar usuário: ' + error.message 
      });
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ 
          success: false, 
          error: 'Email e senha são obrigatórios' 
        });
      }

      const user = await userRepository.findByEmail(email);
      if (!user) {
        return res.status(401).json({ 
          success: false, 
          error: 'Email ou senha inválidos' 
        });
      }

      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        return res.status(401).json({ 
          success: false, 
          error: 'Email ou senha inválidos' 
        });
      }

      const token = jwt.sign(
        { userId: user._id.toString(), email: user.email, userType: user.userType },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.json({
        success: true,
        user: {
          id: user._id.toString(),
          email: user.email,
          name: user.name,
          userType: user.userType,
        },
        token,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao fazer login: ' + error.message 
      });
    }
  }
}

module.exports = new AuthController();


