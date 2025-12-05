const Ad = require('../models/Ad');

class AdRepository {
  async create(adData) {
    try {
      const ad = new Ad(adData);
      return await ad.save();
    } catch (error) {
      throw error;
    }
  }

  async findByProfessionalId(professionalId, options = {}) {
    try {
      const { limit = 50, skip = 0, isActive } = options;
      const filter = { professionalId };
      
      if (isActive !== undefined) {
        filter.isActive = isActive;
      }

      return await Ad.find(filter)
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await Ad.findById(id);
    } catch (error) {
      throw error;
    }
  }

  async findActiveAds(options = {}) {
    try {
      const { limit = 50, skip = 0, category, professionalId } = options;
      const filter = { isActive: true };
      
      if (category) {
        filter.category = category;
      }
      
      if (professionalId) {
        filter.professionalId = professionalId;
      }

      // Filtrar anúncios expirados
      filter.$or = [
        { expiresAt: null },
        { expiresAt: { $gt: new Date() } }
      ];

      return await Ad.find(filter)
        .populate('professionalId', 'userId')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      return await Ad.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true }
      );
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      return await Ad.findByIdAndDelete(id);
    } catch (error) {
      throw error;
    }
  }

  async countByProfessionalId(professionalId) {
    try {
      return await Ad.countDocuments({ professionalId, isActive: true });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new AdRepository();


