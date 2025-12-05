const favoriteRepository = require('../repositories/favoriteRepository');

class FavoriteController {
  async addFavorite(req, res) {
    try {
      const userId = req.user.userId;
      const { professionalId } = req.body;

      if (!professionalId) {
        return res.status(400).json({ 
          success: false, 
          error: 'ID do profissional é obrigatório' 
        });
      }

      // Verificar se já é favorito
      const existing = await favoriteRepository.findByUserAndProfessional(userId, professionalId);
      if (existing) {
        return res.status(400).json({ 
          success: false, 
          error: 'Profissional já está nos favoritos' 
        });
      }

      const favorite = await favoriteRepository.create({
        userId,
        professionalId,
      });

      res.status(201).json({
        success: true,
        message: 'Profissional adicionado aos favoritos',
        favorite: {
          id: favorite._id.toString(),
          userId: favorite.userId.toString(),
          professionalId: favorite.professionalId.toString(),
        },
      });
    } catch (error) {
      if (error.code === 11000) {
        return res.status(400).json({ 
          success: false, 
          error: 'Profissional já está nos favoritos' 
        });
      }
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao adicionar favorito: ' + error.message 
      });
    }
  }

  async removeFavorite(req, res) {
    try {
      const userId = req.user.userId;
      const { professionalId } = req.params;

      const result = await favoriteRepository.delete(userId, professionalId);

      if (result.deletedCount === 0) {
        return res.status(404).json({ 
          success: false, 
          error: 'Favorito não encontrado' 
        });
      }

      res.json({
        success: true,
        message: 'Profissional removido dos favoritos',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao remover favorito: ' + error.message 
      });
    }
  }

  async getFavorites(req, res) {
    try {
      const userId = req.user.userId;
      const favorites = await favoriteRepository.findByUserId(userId);

      const results = favorites.map(fav => {
        const professional = fav.professionalId;
        const user = professional?.userId;
        
        return {
          id: professional?._id?.toString(),
          professionalId: professional?._id?.toString(),
          name: user?.name || 'Nome não disponível',
          email: user?.email,
          profileImage: user?.profileImage,
          rating: professional?.rating || 0,
          totalReviews: professional?.totalReviews || 0,
          specialty: professional?.categories?.[0] || professional?.bio || 'Profissional',
          categories: professional?.categories || [],
          bio: professional?.bio,
          coverageArea: professional?.coverageArea,
        };
      });

      res.json({
        success: true,
        favorites: results,
        total: results.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar favoritos: ' + error.message 
      });
    }
  }

  async checkFavorite(req, res) {
    try {
      const userId = req.user.userId;
      const { professionalId } = req.params;

      const favorite = await favoriteRepository.findByUserAndProfessional(userId, professionalId);

      res.json({
        success: true,
        isFavorite: favorite != null,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao verificar favorito: ' + error.message 
      });
    }
  }
}

module.exports = new FavoriteController();


