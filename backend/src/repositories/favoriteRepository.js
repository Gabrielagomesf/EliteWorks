const Favorite = require('../models/Favorite');

class FavoriteRepository {
  async create(favoriteData) {
    try {
      const favorite = new Favorite(favoriteData);
      return await favorite.save();
    } catch (error) {
      throw error;
    }
  }

  async findByUserId(userId) {
    try {
      return await Favorite.find({ userId })
        .populate({
          path: 'professionalId',
          populate: { path: 'userId', select: 'name email profileImage' }
        })
        .sort({ createdAt: -1 });
    } catch (error) {
      throw error;
    }
  }

  async findByUserAndProfessional(userId, professionalId) {
    try {
      return await Favorite.findOne({ userId, professionalId });
    } catch (error) {
      throw error;
    }
  }

  async delete(userId, professionalId) {
    try {
      return await Favorite.deleteOne({ userId, professionalId });
    } catch (error) {
      throw error;
    }
  }

  async countByProfessional(professionalId) {
    try {
      return await Favorite.countDocuments({ professionalId });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new FavoriteRepository();


