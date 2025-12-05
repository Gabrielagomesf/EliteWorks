const serviceRepository = require('../repositories/serviceRepository');
const notificationRepository = require('../repositories/notificationRepository');
const paymentRepository = require('../repositories/paymentRepository');
const User = require('../models/User');
const Professional = require('../models/Professional');

class ServiceController {
  async create(req, res) {
    try {
      const serviceData = req.body;
      serviceData.clientId = req.user.userId;
      const service = await serviceRepository.create(serviceData);

      const servicePopulated = await serviceRepository.findById(service._id.toString());
      const professional = await Professional.findById(service.professionalId).populate('userId');
      
      if (professional && professional.userId) {
        await notificationRepository.create({
          userId: professional.userId._id.toString(),
          title: 'Nova solicitação de serviço',
          message: `Você recebeu uma nova solicitação: ${service.title}`,
          type: 'service',
          relatedId: service._id.toString(),
          data: { 
            status: 'pending',
            serviceTitle: service.title,
            clientId: service.clientId.toString(),
          },
        });
      }

      res.status(201).json({
        success: true,
        service: {
          id: service._id.toString(),
          professionalId: service.professionalId.toString(),
          clientId: service.clientId.toString(),
          category: service.category || null,
          title: service.title,
          description: service.description,
          price: service.price,
          status: service.status,
          scheduledDate: service.scheduledDate,
          completedDate: service.completedDate,
          location: service.location || null,
          images: service.images || [],
          createdAt: service.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao criar serviço: ' + error.message 
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const service = await serviceRepository.findById(id);

      if (!service) {
        return res.status(404).json({ 
          success: false, 
          error: 'Serviço não encontrado' 
        });
      }

      res.json({
        success: true,
        service: {
          id: service._id.toString(),
          professionalId: service.professionalId.toString(),
          clientId: service.clientId.toString(),
          category: service.category || null,
          title: service.title,
          description: service.description,
          price: service.price,
          status: service.status,
          scheduledDate: service.scheduledDate,
          completedDate: service.completedDate,
          location: service.location || null,
          images: service.images || [],
          createdAt: service.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar serviço: ' + error.message 
      });
    }
  }

  async getByClientId(req, res) {
    try {
      const { clientId } = req.params;
      const services = await serviceRepository.findByClientId(clientId);

      res.json({
        success: true,
        services: services.map(s => ({
          id: s._id.toString(),
          professionalId: s.professionalId?._id?.toString(),
          professionalName: s.professionalId?.name,
          category: s.category || null,
          title: s.title,
          description: s.description,
          price: s.price,
          status: s.status,
          scheduledDate: s.scheduledDate,
          completedDate: s.completedDate,
          location: s.location || null,
          images: s.images || [],
          createdAt: s.createdAt,
        })),
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar serviços: ' + error.message 
      });
    }
  }

  async getByProfessionalId(req, res) {
    try {
      const { professionalId } = req.params;
      const services = await serviceRepository.findByProfessionalId(professionalId);

      res.json({
        success: true,
        services: services.map(s => ({
          id: s._id.toString(),
          clientId: s.clientId?._id?.toString(),
          clientName: s.clientId?.name,
          category: s.category || null,
          title: s.title,
          description: s.description,
          price: s.price,
          status: s.status,
          scheduledDate: s.scheduledDate,
          completedDate: s.completedDate,
          location: s.location || null,
          images: s.images || [],
          createdAt: s.createdAt,
        })),
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar serviços: ' + error.message 
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;
      const oldService = await serviceRepository.findById(id)
        .populate('clientId')
        .populate('professionalId');

      if (!oldService) {
        return res.status(404).json({ 
          success: false, 
          error: 'Serviço não encontrado' 
        });
      }

      const service = await serviceRepository.update(id, updates);

      // Criar notificações automáticas baseadas na mudança de status
      if (updates.status && updates.status !== oldService.status) {
        await this._createStatusChangeNotification(oldService, updates.status);
      }

      res.json({
        success: true,
        service: {
          id: service._id.toString(),
          professionalId: service.professionalId.toString(),
          clientId: service.clientId.toString(),
          category: service.category || null,
          title: service.title,
          description: service.description,
          price: service.price,
          status: service.status,
          scheduledDate: service.scheduledDate,
          completedDate: service.completedDate,
          location: service.location || null,
          images: service.images || [],
          createdAt: service.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao atualizar serviço: ' + error.message 
      });
    }
  }

  async _createStatusChangeNotification(service, newStatus) {
    try {
      const client = await User.findById(service.clientId);
      const professional = await Professional.findById(service.professionalId).populate('userId');
      
      if (!client || !professional || !professional.userId) return;

      const professionalUser = professional.userId;
      const serviceTitle = service.title || 'Serviço';

      switch (newStatus) {
        case 'accepted':
          // Notificar o cliente que o serviço foi aceito
          await notificationRepository.create({
            userId: service.clientId._id ? service.clientId._id.toString() : service.clientId.toString(),
            title: 'Serviço aceito',
            message: `${professionalUser.name} aceitou sua solicitação de serviço: ${serviceTitle}`,
            type: 'service',
            relatedId: service._id,
            data: { status: 'accepted', professionalName: professionalUser.name },
          });
          break;

        case 'in_progress':
          // Notificar o cliente que o serviço está em andamento
          await notificationRepository.create({
            userId: service.clientId._id ? service.clientId._id.toString() : service.clientId.toString(),
            title: 'Serviço em andamento',
            message: `${professionalUser.name} iniciou o serviço: ${serviceTitle}`,
            type: 'service',
            relatedId: service._id,
            data: { status: 'in_progress' },
          });
          break;

        case 'completed':
          // Notificar ambos
          const clientName = client.name || 'Cliente';
          await notificationRepository.create({
            userId: service.clientId._id ? service.clientId._id.toString() : service.clientId.toString(),
            title: 'Serviço concluído',
            message: `O serviço "${serviceTitle}" foi concluído por ${professionalUser.name}`,
            type: 'service',
            relatedId: service._id,
            data: { status: 'completed' },
          });
          
          await notificationRepository.create({
            userId: professionalUser._id,
            title: 'Serviço concluído',
            message: `Você concluiu o serviço "${serviceTitle}" para ${clientName}`,
            type: 'service',
            relatedId: service._id,
            data: { status: 'completed', canReview: true },
          });
          break;

        case 'cancelled':
          // Notificar o profissional se o cliente cancelou
          const clientNameCancel = client.name || 'Cliente';
          await notificationRepository.create({
            userId: professionalUser._id,
            title: 'Serviço cancelado',
            message: `${clientNameCancel} cancelou o serviço: ${serviceTitle}`,
            type: 'service',
            relatedId: service._id,
            data: { status: 'cancelled' },
          });
          break;
      }
    } catch (error) {
      console.error('Erro ao criar notificação de mudança de status:', error);
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await serviceRepository.delete(id);

      res.json({
        success: true,
        message: 'Serviço deletado com sucesso',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao deletar serviço: ' + error.message 
      });
    }
  }
}

module.exports = new ServiceController();

