const Payment = require('../models/Payment');

class PaymentRepository {
  async create(paymentData) {
    try {
      const payment = new Payment(paymentData);
      return await payment.save();
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await Payment.findById(id)
        .populate('serviceId')
        .populate('clientId', 'name email')
        .populate('professionalId', 'name email');
    } catch (error) {
      throw error;
    }
  }

  async findByServiceId(serviceId) {
    try {
      return await Payment.find({ serviceId })
        .populate('clientId', 'name email')
        .populate('professionalId', 'name email')
        .sort({ createdAt: -1 });
    } catch (error) {
      throw error;
    }
  }

  async findByClientId(clientId, options = {}) {
    try {
      const { limit = 50, skip = 0, status } = options;
      const filter = { clientId };
      
      if (status) {
        filter.status = status;
      }

      return await Payment.find(filter)
        .populate('serviceId', 'title description')
        .populate('professionalId', 'name email')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async findByProfessionalId(professionalId, options = {}) {
    try {
      const { limit = 50, skip = 0, status } = options;
      const filter = { professionalId };
      
      if (status) {
        filter.status = status;
      }

      return await Payment.find(filter)
        .populate('serviceId', 'title description')
        .populate('clientId', 'name email')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      return await Payment.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true, runValidators: true }
      )
        .populate('serviceId')
        .populate('clientId', 'name email')
        .populate('professionalId', 'name email');
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      return await Payment.findByIdAndDelete(id);
    } catch (error) {
      throw error;
    }
  }

  async getTotalByClientId(clientId, status = 'completed') {
    try {
      const payments = await Payment.find({ clientId, status });
      return payments.reduce((total, payment) => total + payment.amount, 0);
    } catch (error) {
      throw error;
    }
  }

  async getTotalByProfessionalId(professionalId, status = 'completed') {
    try {
      const payments = await Payment.find({ professionalId, status });
      return payments.reduce((total, payment) => total + payment.amount, 0);
    } catch (error) {
      throw error;
    }
  }

  async findByTransactionId(transactionId) {
    try {
      return await Payment.findOne({ transactionId })
        .populate('serviceId')
        .populate('clientId', 'name email')
        .populate('professionalId', 'name email');
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new PaymentRepository();


