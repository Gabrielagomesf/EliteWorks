const notificationRepository = require('../repositories/notificationRepository');

class NotificationController {
  async create(req, res) {
    try {
      const { userId, title, message, type, relatedId, data } = req.body;

      if (!userId || !title || !message) {
        return res.status(400).json({ 
          success: false, 
          error: 'userId, title e message são obrigatórios' 
        });
      }

      const notification = await notificationRepository.create({
        userId,
        title,
        message,
        type: type || 'info',
        relatedId,
        data,
      });

      res.status(201).json({
        success: true,
        notification: {
          id: notification._id.toString(),
          userId: notification.userId.toString(),
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: notification.isRead,
          relatedId: notification.relatedId?.toString(),
          data: notification.data,
          createdAt: notification.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao criar notificação: ' + error.message 
      });
    }
  }

  async getNotifications(req, res) {
    try {
      const userId = req.user.userId;
      const { limit = 50, skip = 0, isRead, type } = req.query;

      const options = {
        limit: parseInt(limit),
        skip: parseInt(skip),
        isRead: isRead === 'true' ? true : isRead === 'false' ? false : undefined,
        type,
      };

      const notifications = await notificationRepository.findByUserId(userId, options);
      const unreadCount = await notificationRepository.countUnread(userId);

      res.json({
        success: true,
        notifications: notifications.map(n => ({
          id: n._id.toString(),
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: n.isRead,
          relatedId: n.relatedId?.toString(),
          data: n.data,
          createdAt: n.createdAt,
        })),
        unreadCount,
        total: notifications.length,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao buscar notificações: ' + error.message 
      });
    }
  }

  async markAsRead(req, res) {
    try {
      const { id } = req.params;
      const notification = await notificationRepository.markAsRead(id);

      if (!notification) {
        return res.status(404).json({ 
          success: false, 
          error: 'Notificação não encontrada' 
        });
      }

      res.json({
        success: true,
        message: 'Notificação marcada como lida',
        notification: {
          id: notification._id.toString(),
          isRead: notification.isRead,
        },
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao marcar notificação como lida: ' + error.message 
      });
    }
  }

  async markAllAsRead(req, res) {
    try {
      const userId = req.user.userId;
      await notificationRepository.markAllAsRead(userId);

      res.json({
        success: true,
        message: 'Todas as notificações foram marcadas como lidas',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao marcar todas como lidas: ' + error.message 
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      const notification = await notificationRepository.delete(id);

      if (!notification) {
        return res.status(404).json({ 
          success: false, 
          error: 'Notificação não encontrada' 
        });
      }

      res.json({
        success: true,
        message: 'Notificação deletada com sucesso',
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao deletar notificação: ' + error.message 
      });
    }
  }

  async getUnreadCount(req, res) {
    try {
      const userId = req.user.userId;
      const count = await notificationRepository.countUnread(userId);

      res.json({
        success: true,
        unreadCount: count,
      });
    } catch (error) {
      res.status(500).json({ 
        success: false, 
        error: 'Erro ao contar notificações não lidas: ' + error.message 
      });
    }
  }
}

module.exports = new NotificationController();


