const Review = require('../models/Review');
const Professional = require('../models/Professional');

class ReviewRepository {
  async create(reviewData) {
    try {
      const review = new Review(reviewData);
      const savedReview = await review.save();
      
      // Atualizar rating do profissional
      await this._updateProfessionalRating(reviewData.professionalId);
      
      return savedReview;
    } catch (error) {
      throw error;
    }
  }

  async _updateProfessionalRating(professionalId) {
    try {
      const reviews = await Review.find({ professionalId });
      
      if (reviews.length === 0) {
        await Professional.findByIdAndUpdate(professionalId, {
          $set: { rating: 0, totalReviews: 0 }
        });
        return;
      }

      const totalRating = reviews.reduce((sum, r) => sum + r.rating, 0);
      const averageRating = totalRating / reviews.length;

      await Professional.findByIdAndUpdate(professionalId, {
        $set: { 
          rating: Math.round(averageRating * 10) / 10, // Arredondar para 1 casa decimal
          totalReviews: reviews.length 
        }
      });
    } catch (error) {
      console.error('Erro ao atualizar rating do profissional:', error);
    }
  }

  async findByProfessionalId(professionalId, options = {}) {
    try {
      const { limit = 50, skip = 0 } = options;
      return await Review.find({ professionalId })
        .populate('clientId', 'name email profileImage')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async findByServiceId(serviceId) {
    try {
      return await Review.findOne({ serviceId })
        .populate('clientId', 'name email profileImage');
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await Review.findById(id)
        .populate('clientId', 'name email profileImage');
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      const review = await Review.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true }
      );
      
      if (review) {
        await this._updateProfessionalRating(review.professionalId);
      }
      
      return review;
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      const review = await Review.findById(id);
      if (review) {
        await Review.findByIdAndDelete(id);
        await this._updateProfessionalRating(review.professionalId);
      }
      return review;
    } catch (error) {
      throw error;
    }
  }

  async countByProfessionalId(professionalId) {
    try {
      return await Review.countDocuments({ professionalId });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ReviewRepository();


