const Service = require('../models/Service');

class ServiceRepository {
  async create(serviceData) {
    try {
      const service = new Service(serviceData);
      return await service.save();
    } catch (error) {
      throw error;
    }
  }

  async findById(id, populate = true) {
    try {
      let query = Service.findById(id);
      if (populate) {
        query = query.populate('clientId').populate('professionalId');
      }
      return await query;
    } catch (error) {
      throw error;
    }
  }

  async findByClientId(clientId) {
    try {
      return await Service.find({ clientId })
        .populate('professionalId')
        .sort({ createdAt: -1 });
    } catch (error) {
      throw error;
    }
  }

  async findByProfessionalId(professionalId) {
    try {
      return await Service.find({ professionalId })
        .populate('clientId')
        .sort({ createdAt: -1 });
    } catch (error) {
      throw error;
    }
  }

  async update(id, updates) {
    try {
      return await Service.findByIdAndUpdate(
        id,
        { $set: updates },
        { new: true, runValidators: true }
      );
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      return await Service.findByIdAndDelete(id);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ServiceRepository();

