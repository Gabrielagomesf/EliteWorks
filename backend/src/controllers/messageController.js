const messageRepository = require('../repositories/messageRepository');
const notificationRepository = require('../repositories/notificationRepository');
const Message = require('../models/Message');

class MessageController {
  async sendMessage(req, res) {
    try {
      const { receiverId, message, serviceId } = req.body;
      const senderId = req.user.userId;

      if (!receiverId || !message) {
        return res.status(400).json({
          success: false,
          error: 'receiverId e message são obrigatórios',
        });
      }

      const newMessage = await messageRepository.create({
        senderId,
        receiverId,
        message,
        serviceId,
      });

      const populatedMessage = await Message.findById(newMessage._id)
        .populate('senderId', 'name email profileImage')
        .populate('receiverId', 'name email profileImage');

      const senderName = populatedMessage.senderId?.name ?? 'Alguém';
      await notificationRepository.create({
        userId: receiverId,
        title: 'Nova mensagem',
        message: `Você recebeu uma nova mensagem de ${senderName}`,
        type: 'message',
        relatedId: newMessage._id,
        data: { senderId: senderId.toString() },
      });

      res.status(201).json({
        success: true,
        message: {
          id: populatedMessage._id.toString(),
          senderId: populatedMessage.senderId?._id?.toString() ?? populatedMessage.senderId?.toString() ?? '',
          senderName: populatedMessage.senderId?.name ?? 'Usuário',
          receiverId: populatedMessage.receiverId?._id?.toString() ?? populatedMessage.receiverId?.toString() ?? '',
          receiverName: populatedMessage.receiverId?.name ?? 'Usuário',
          message: populatedMessage.message,
          serviceId: populatedMessage.serviceId?.toString(),
          isRead: populatedMessage.isRead,
          createdAt: populatedMessage.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao enviar mensagem: ' + error.message,
      });
    }
  }

  async getConversation(req, res) {
    try {
      const { otherUserId } = req.params;
      const userId = req.user.userId;
      const { limit = 50, skip = 0 } = req.query;

      const messages = await messageRepository.findConversation(userId, otherUserId, {
        limit: parseInt(limit),
        skip: parseInt(skip),
      });

      await messageRepository.markConversationAsRead(userId, otherUserId);

      res.json({
        success: true,
        messages: messages.map(m => ({
          id: m._id.toString(),
          senderId: m.senderId?._id?.toString() ?? m.senderId?.toString() ?? '',
          senderName: m.senderId?.name ?? 'Usuário',
          receiverId: m.receiverId?._id?.toString() ?? m.receiverId?.toString() ?? '',
          receiverName: m.receiverId?.name ?? 'Usuário',
          message: m.message,
          serviceId: m.serviceId?.toString(),
          isRead: m.isRead,
          createdAt: m.createdAt,
        })),
        total: messages.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar conversa: ' + error.message,
      });
    }
  }

  async getConversations(req, res) {
    try {
      const userId = req.user.userId;
      const conversations = await messageRepository.findUserConversations(userId);

      res.json({
        success: true,
        conversations: conversations.map(c => ({
          userId: c.userId.toString(),
          userName: c.userName,
          userEmail: c.userEmail,
          userProfileImage: c.userProfileImage,
          lastMessage: c.lastMessage ? {
            id: c.lastMessage.id.toString(),
            message: c.lastMessage.message,
            senderId: c.lastMessage.senderId.toString(),
            createdAt: c.lastMessage.createdAt,
          } : null,
          unreadCount: c.unreadCount,
        })),
        total: conversations.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar conversas: ' + error.message,
      });
    }
  }

  async markAsRead(req, res) {
    try {
      const { messageIds } = req.body;
      const userId = req.user.userId;

      if (!messageIds || !Array.isArray(messageIds)) {
        return res.status(400).json({
          success: false,
          error: 'messageIds deve ser um array',
        });
      }

      await messageRepository.markAsRead(messageIds, userId);

      res.json({
        success: true,
        message: 'Mensagens marcadas como lidas',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao marcar mensagens como lidas: ' + error.message,
      });
    }
  }

  async markConversationAsRead(req, res) {
    try {
      const { otherUserId } = req.params;
      const userId = req.user.userId;

      await messageRepository.markConversationAsRead(userId, otherUserId);

      res.json({
        success: true,
        message: 'Conversa marcada como lida',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao marcar conversa como lida: ' + error.message,
      });
    }
  }

  async getUnreadCount(req, res) {
    try {
      const userId = req.user.userId;
      const count = await messageRepository.countUnread(userId);

      res.json({
        success: true,
        unreadCount: count,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao contar mensagens não lidas: ' + error.message,
      });
    }
  }

  async deleteMessage(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.userId;

      const message = await messageRepository.delete(id, userId);

      if (!message) {
        return res.status(404).json({
          success: false,
          error: 'Mensagem não encontrada',
        });
      }

      res.json({
        success: true,
        message: 'Mensagem deletada com sucesso',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao deletar mensagem: ' + error.message,
      });
    }
  }
}

module.exports = new MessageController();

