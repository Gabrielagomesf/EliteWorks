const adRepository = require('../repositories/adRepository');
const professionalRepository = require('../repositories/professionalRepository');

class AdController {
  async create(req, res) {
    try {
      const { title, description, category, price, images, expiresAt, details } = req.body;
      const userId = req.user.userId;

      if (!title || !category) {
        return res.status(400).json({ 
          success: false, 
          error: 'title e category são obrigatórios' 
        });
      }

      const professional = await professionalRepository.findByUserId(userId);
      if (!professional) {
        return res.status(404).json({ 
          success: false, 
          error: 'Profissional não encontrado' 
        });
      }

      const ad = await adRepository.create({
        professionalId: professional._id.toString(),
        title,
        description,
        category,
        price: price || 0,
        images: images || [],
        expiresAt: expiresAt ? new Date(expiresAt) : null,
        details,
      });

      res.status(201).json({
        success: true,
        ad: {
          id: ad._id.toString(),
          professionalId: ad.professionalId.toString(),
          title: ad.title,
          description: ad.description,
          category: ad.category,
          price: ad.price,
          images: ad.images,
          isActive: ad.isActive,
          expiresAt: ad.expiresAt,
          details: ad.details,
          createdAt: ad.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao criar anúncio: ' + error.message 
      });
    }
  }

  async getByProfessionalId(req, res) {
    try {
      const { professionalId } = req.params;
      const { limit = 50, skip = 0, isActive } = req.query;

      const ads = await adRepository.findByProfessionalId(professionalId, {
        limit: parseInt(limit),
        skip: parseInt(skip),
        isActive: isActive === 'true' ? true : isActive === 'false' ? false : undefined,
      });

      res.json({
        success: true,
        ads: ads.map(a => ({
          id: a._id.toString(),
          professionalId: a.professionalId.toString(),
          title: a.title,
          description: a.description,
          category: a.category,
          price: a.price,
          images: a.images,
          isActive: a.isActive,
          expiresAt: a.expiresAt,
          details: a.details,
          createdAt: a.createdAt,
        })),
        total: ads.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar anúncios: ' + error.message 
      });
    }
  }

  async getActiveAds(req, res) {
    try {
      const { limit = 50, skip = 0, category, professionalId } = req.query;

      const ads = await adRepository.findActiveAds({
        limit: parseInt(limit),
        skip: parseInt(skip),
        category,
        professionalId,
      });

      res.json({
        success: true,
        ads: ads.map(a => ({
          id: a._id.toString(),
          professionalId: a.professionalId.toString(),
          title: a.title,
          description: a.description,
          category: a.category,
          price: a.price,
          images: a.images,
          isActive: a.isActive,
          expiresAt: a.expiresAt,
          details: a.details,
          createdAt: a.createdAt,
        })),
        total: ads.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar anúncios ativos: ' + error.message 
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const ad = await adRepository.findById(id);

      if (!ad) {
        return res.status(404).json({ 
          success: false, 
          error: 'Anúncio não encontrado' 
        });
      }

      res.json({
        success: true,
        ad: {
          id: ad._id.toString(),
          professionalId: ad.professionalId.toString(),
          title: ad.title,
          description: ad.description,
          category: ad.category,
          price: ad.price,
          images: ad.images,
          isActive: ad.isActive,
          expiresAt: ad.expiresAt,
          details: ad.details,
          createdAt: ad.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar anúncio: ' + error.message 
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;

      if (updates.expiresAt) {
        updates.expiresAt = new Date(updates.expiresAt);
      }

      const ad = await adRepository.update(id, updates);

      if (!ad) {
        return res.status(404).json({ 
          success: false, 
          error: 'Anúncio não encontrado' 
        });
      }

      res.json({
        success: true,
        ad: {
          id: ad._id.toString(),
          professionalId: ad.professionalId.toString(),
          title: ad.title,
          description: ad.description,
          category: ad.category,
          price: ad.price,
          images: ad.images,
          isActive: ad.isActive,
          expiresAt: ad.expiresAt,
          details: ad.details,
          createdAt: ad.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao atualizar anúncio: ' + error.message 
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      const ad = await adRepository.delete(id);

      if (!ad) {
        return res.status(404).json({ 
          success: false, 
          error: 'Anúncio não encontrado' 
        });
      }

      res.json({
        success: true,
        message: 'Anúncio deletado com sucesso',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao deletar anúncio: ' + error.message 
      });
    }
  }
}

module.exports = new AdController();


