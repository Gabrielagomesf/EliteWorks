const reviewRepository = require('../repositories/reviewRepository');
const notificationRepository = require('../repositories/notificationRepository');

class ReviewController {
  async create(req, res) {
    try {
      const { professionalId, serviceId, rating, comment } = req.body;
      const clientId = req.user.userId;

      if (!professionalId || !rating) {
        return res.status(400).json({ 
          success: false, 
          error: 'professionalId e rating são obrigatórios' 
        });
      }

      if (rating < 1 || rating > 5) {
        return res.status(400).json({ 
          success: false, 
          error: 'Rating deve estar entre 1 e 5' 
        });
      }

      // Verificar se já existe review para este serviço
      if (serviceId) {
        const existingReview = await reviewRepository.findByServiceId(serviceId);
        if (existingReview) {
          return res.status(400).json({ 
            success: false, 
            error: 'Já existe uma avaliação para este serviço' 
          });
        }
      }

      const review = await reviewRepository.create({
        professionalId,
        clientId,
        serviceId,
        rating,
        comment,
      });

      // Criar notificação para o profissional
      const User = require('../models/User');
      const client = await User.findById(clientId);
      if (client) {
        const Professional = require('../models/Professional');
        const professional = await Professional.findById(professionalId).populate('userId');
        if (professional && professional.userId) {
          await notificationRepository.create({
            userId: professional.userId._id,
            title: 'Nova avaliação recebida',
            message: `${client.name} avaliou você com ${rating} estrela${rating > 1 ? 's' : ''}`,
            type: 'review',
            relatedId: review._id,
            data: { rating, serviceId },
          });
        }
      }

      res.status(201).json({
        success: true,
        review: {
          id: review._id.toString(),
          professionalId: review.professionalId.toString(),
          clientId: review.clientId.toString(),
          serviceId: review.serviceId?.toString(),
          rating: review.rating,
          comment: review.comment,
          createdAt: review.createdAt,
        },
      });
    } catch (error) {
      if (error.code === 11000) {
        return res.status(400).json({ 
          success: false, 
          error: 'Já existe uma avaliação para este serviço' 
        });
      }
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao criar avaliação: ' + error.message 
      });
    }
  }

  async getByProfessionalId(req, res) {
    try {
      const { professionalId } = req.params;
      const { limit = 50, skip = 0 } = req.query;

      const reviews = await reviewRepository.findByProfessionalId(professionalId, {
        limit: parseInt(limit),
        skip: parseInt(skip),
      });

      res.json({
        success: true,
        reviews: reviews.map(r => ({
          id: r._id.toString(),
          professionalId: r.professionalId.toString(),
          clientId: r.clientId?._id?.toString(),
          clientName: r.clientId?.name || 'Cliente',
          serviceId: r.serviceId?.toString(),
          rating: r.rating,
          comment: r.comment,
          createdAt: r.createdAt,
        })),
        total: reviews.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar avaliações: ' + error.message 
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const review = await reviewRepository.findById(id);

      if (!review) {
        return res.status(404).json({ 
          success: false, 
          error: 'Avaliação não encontrada' 
        });
      }

      res.json({
        success: true,
        review: {
          id: review._id.toString(),
          professionalId: review.professionalId.toString(),
          clientId: review.clientId?._id?.toString(),
          clientName: review.clientId?.name || 'Cliente',
          serviceId: review.serviceId?.toString(),
          rating: review.rating,
          comment: review.comment,
          createdAt: review.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar avaliação: ' + error.message 
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const { rating, comment } = req.body;
      const updates = {};

      if (rating !== undefined) {
        if (rating < 1 || rating > 5) {
          return res.status(400).json({ 
            success: false, 
            error: 'Rating deve estar entre 1 e 5' 
          });
        }
        updates.rating = rating;
      }

      if (comment !== undefined) {
        updates.comment = comment;
      }

      const review = await reviewRepository.update(id, updates);

      if (!review) {
        return res.status(404).json({ 
          success: false, 
          error: 'Avaliação não encontrada' 
        });
      }

      res.json({
        success: true,
        review: {
          id: review._id.toString(),
          professionalId: review.professionalId.toString(),
          clientId: review.clientId.toString(),
          serviceId: review.serviceId?.toString(),
          rating: review.rating,
          comment: review.comment,
          createdAt: review.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao atualizar avaliação: ' + error.message 
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      const review = await reviewRepository.delete(id);

      if (!review) {
        return res.status(404).json({ 
          success: false, 
          error: 'Avaliação não encontrada' 
        });
      }

      res.json({
        success: true,
        message: 'Avaliação deletada com sucesso',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao deletar avaliação: ' + error.message 
      });
    }
  }
}

module.exports = new ReviewController();


