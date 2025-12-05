const Message = require('../models/Message');

class MessageRepository {
  async create(messageData) {
    try {
      const message = new Message(messageData);
      return await message.save();
    } catch (error) {
      throw error;
    }
  }

  async findConversation(userId1, userId2, options = {}) {
    try {
      const { limit = 50, skip = 0 } = options;
      return await Message.find({
        $or: [
          { senderId: userId1, receiverId: userId2 },
          { senderId: userId2, receiverId: userId1 },
        ],
      })
        .populate('senderId', 'name email profileImage')
        .populate('receiverId', 'name email profileImage')
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async findUserConversations(userId) {
    try {
      const userIdObj = new mongoose.Types.ObjectId(userId);
      const conversations = await Message.aggregate([
        {
          $match: {
            $or: [
              { senderId: userIdObj },
              { receiverId: userIdObj },
            ],
          },
        },
        {
          $sort: { createdAt: -1 },
        },
        {
          $group: {
            _id: {
              $cond: [
                { $eq: ['$senderId', userIdObj] },
                '$receiverId',
                '$senderId',
              ],
            },
            lastMessage: { $first: '$$ROOT' },
            unreadCount: {
              $sum: {
                $cond: [
                  {
                    $and: [
                      { $eq: ['$receiverId', userIdObj] },
                      { $eq: ['$isRead', false] },
                    ],
                  },
                  1,
                  0,
                ],
              },
            },
          },
        },
        {
          $lookup: {
            from: 'users',
            localField: '_id',
            foreignField: '_id',
            as: 'user',
          },
        },
        {
          $unwind: '$user',
        },
        {
          $project: {
            userId: '$_id',
            userName: '$user.name',
            userEmail: '$user.email',
            userProfileImage: '$user.profileImage',
            lastMessage: {
              id: '$lastMessage._id',
              message: '$lastMessage.message',
              senderId: '$lastMessage.senderId',
              createdAt: '$lastMessage.createdAt',
            },
            unreadCount: 1,
          },
        },
        {
          $sort: { 'lastMessage.createdAt': -1 },
        },
      ]);

      return conversations;
    } catch (error) {
      throw error;
    }
  }

  async markAsRead(messageIds, userId) {
    try {
      return await Message.updateMany(
        {
          _id: { $in: messageIds },
          receiverId: userId,
        },
        { $set: { isRead: true } }
      );
    } catch (error) {
      throw error;
    }
  }

  async markConversationAsRead(userId1, userId2) {
    try {
      return await Message.updateMany(
        {
          senderId: userId2,
          receiverId: userId1,
          isRead: false,
        },
        { $set: { isRead: true } }
      );
    } catch (error) {
      throw error;
    }
  }

  async countUnread(userId) {
    try {
      return await Message.countDocuments({
        receiverId: userId,
        isRead: false,
      });
    } catch (error) {
      throw error;
    }
  }

  async delete(messageId, userId) {
    try {
      const message = await Message.findById(messageId);
      if (!message) {
        return null;
      }

      if (message.senderId.toString() !== userId.toString()) {
        throw new Error('Você não tem permissão para deletar esta mensagem');
      }

      return await Message.findByIdAndDelete(messageId);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new MessageRepository();

