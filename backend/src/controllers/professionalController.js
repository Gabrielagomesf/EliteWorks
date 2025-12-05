const professionalRepository = require('../repositories/professionalRepository');

class ProfessionalController {
  async search(req, res) {
    try {
      const {
        query,
        category,
        minRating,
        maxPrice,
        location,
        limit = 20,
        skip = 0,
      } = req.query;

      const professionals = await professionalRepository.search({
        query,
        category,
        minRating: minRating ? parseFloat(minRating) : undefined,
        maxPrice: maxPrice ? parseFloat(maxPrice) : undefined,
        location,
        limit: parseInt(limit),
        skip: parseInt(skip),
      });

      const results = professionals.map(p => ({
        professional: {
          id: p._id.toString(),
          specialty: p.specialty,
          bio: p.bio,
          categories: p.categories,
          rating: p.rating,
          totalReviews: p.totalReviews,
          hourlyRate: p.hourlyRate,
          coverageArea: p.coverageArea,
        },
        user: p.userId ? {
          id: p.userId._id.toString(),
          name: p.userId.name,
          email: p.userId.email,
          profileImage: p.userId.profileImage,
        } : null,
      }));

      res.json({
        success: true,
        results,
        total: results.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar profissionais: ' + error.message 
      });
    }
  }

  async getFeatured(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 10;
      const professionals = await professionalRepository.getFeatured(limit);

      const results = professionals.map(p => ({
        professional: {
          id: p._id.toString(),
          specialty: p.specialty,
          bio: p.bio,
          categories: p.categories,
          rating: p.rating,
          totalReviews: p.totalReviews,
          hourlyRate: p.hourlyRate,
        },
        user: p.userId ? {
          id: p.userId._id.toString(),
          name: p.userId.name,
          email: p.userId.email,
          profileImage: p.userId.profileImage,
        } : null,
      }));

      res.json({
        success: true,
        results,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar profissionais em destaque: ' + error.message 
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const professional = await professionalRepository.findById(id);

      if (!professional) {
        return res.status(404).json({ 
          success: false, 
          error: 'Profissional não encontrado' 
        });
      }

      res.json({
        success: true,
        professional: {
          id: professional._id.toString(),
          specialty: professional.specialty,
          bio: professional.bio,
          categories: professional.categories,
          rating: professional.rating,
          totalReviews: professional.totalReviews,
          hourlyRate: professional.hourlyRate,
          coverageArea: professional.coverageArea,
          experience: professional.experience,
          certifications: professional.certifications,
          portfolio: professional.portfolio,
          availability: professional.availability,
        },
        user: professional.userId ? {
          id: professional.userId._id.toString(),
          name: professional.userId.name,
          email: professional.userId.email,
          phone: professional.userId.phone,
          profileImage: professional.userId.profileImage,
        } : null,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar profissional: ' + error.message 
      });
    }
  }

  async count(req, res) {
    try {
      const {
        query,
        category,
        minRating,
        maxPrice,
        location,
      } = req.query;

      const filters = {};
      if (query) filters.query = query;
      if (category) filters.category = category;
      if (minRating) filters.minRating = parseFloat(minRating);
      if (maxPrice) filters.maxPrice = parseFloat(maxPrice);
      if (location) filters.location = location;

      const total = await professionalRepository.count(filters);

      res.json({
        success: true,
        total,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao contar profissionais: ' + error.message 
      });
    }
  }
}

module.exports = new ProfessionalController();

