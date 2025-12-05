const Professional = require('../models/Professional');

class ProfessionalRepository {
  async create(professionalData) {
    try {
      const professional = new Professional(professionalData);
      return await professional.save();
    } catch (error) {
      throw error;
    }
  }

  async findByUserId(userId) {
    try {
      return await Professional.findOne({ userId });
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await Professional.findById(id).populate('userId');
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      return await Professional.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true, runValidators: true }
      );
    } catch (error) {
      throw error;
    }
  }

  async deleteByUserId(userId) {
    try {
      return await Professional.deleteOne({ userId });
    } catch (error) {
      throw error;
    }
  }

  async getFeatured(limit = 10) {
    try {
      return await Professional.find()
        .sort({ rating: -1 })
        .limit(limit)
        .populate('userId');
    } catch (error) {
      throw error;
    }
  }

  async search({ query, category, minRating, maxPrice, location, limit = 20, skip = 0 }) {
    try {
      const filter = {};

      if (category) {
        filter.categories = category;
      }

      if (minRating !== undefined) {
        filter.rating = { $gte: minRating };
      }

      if (location) {
        filter.coverageArea = { $regex: location, $options: 'i' };
      }

      let professionals = await Professional.find(filter)
        .limit(limit)
        .skip(skip)
        .populate('userId');

      if (query) {
        const queryLower = query.toLowerCase();
        professionals = professionals.filter(p => {
          const user = p.userId;
          if (!user) return false;
          
          const nameMatch = user.name?.toLowerCase().includes(queryLower);
          const bioMatch = p.bio?.toLowerCase().includes(queryLower);
          const categoryMatch = p.categories?.some(c => 
            c.toLowerCase().includes(queryLower)
          );
          
          return nameMatch || bioMatch || categoryMatch;
        });
      }

      if (maxPrice !== undefined) {
        professionals = professionals.filter(p => 
          !p.hourlyRate || p.hourlyRate <= maxPrice
        );
      }

      return professionals;
    } catch (error) {
      throw error;
    }
  }

  async count(filters = {}) {
    try {
      const filter = {};

      if (filters.category) {
        filter.categories = filters.category;
      }

      if (filters.minRating !== undefined) {
        filter.rating = { $gte: filters.minRating };
      }

      if (filters.location) {
        filter.coverageArea = { $regex: filters.location, $options: 'i' };
      }

      // Para query e maxPrice, precisamos buscar e filtrar em memória
      if (filters.query || filters.maxPrice !== undefined) {
        let professionals = await Professional.find(filter).populate('userId');
        
        if (filters.query) {
          const queryLower = filters.query.toLowerCase();
          professionals = professionals.filter(p => {
            const user = p.userId;
            if (!user) return false;
            
            const nameMatch = user.name?.toLowerCase().includes(queryLower);
            const bioMatch = p.bio?.toLowerCase().includes(queryLower);
            const categoryMatch = p.categories?.some(c => 
              c.toLowerCase().includes(queryLower)
            );
            
            return nameMatch || bioMatch || categoryMatch;
          });
        }

        if (filters.maxPrice !== undefined) {
          professionals = professionals.filter(p => 
            !p.hourlyRate || p.hourlyRate <= filters.maxPrice
          );
        }

        return professionals.length;
      }

      return await Professional.countDocuments(filter);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ProfessionalRepository();

