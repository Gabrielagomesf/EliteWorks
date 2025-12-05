const Notification = require('../models/Notification');

class NotificationRepository {
  async create(notificationData) {
    try {
      const notification = new Notification(notificationData);
      return await notification.save();
    } catch (error) {
      throw error;
    }
  }

  async findByUserId(userId, options = {}) {
    try {
      const { limit = 50, skip = 0, isRead, type } = options;
      const filter = { userId };
      
      if (isRead !== undefined) {
        filter.isRead = isRead;
      }
      
      if (type) {
        filter.type = type;
      }

      return await Notification.find(filter)
        .sort({ createdAt: -1 })
        .limit(limit)
        .skip(skip);
    } catch (error) {
      throw error;
    }
  }

  async findById(id) {
    try {
      return await Notification.findById(id);
    } catch (error) {
      throw error;
    }
  }

  async markAsRead(id) {
    try {
      return await Notification.findByIdAndUpdate(
        id,
        { $set: { isRead: true } },
        { new: true }
      );
    } catch (error) {
      throw error;
    }
  }

  async markAllAsRead(userId) {
    try {
      return await Notification.updateMany(
        { userId, isRead: false },
        { $set: { isRead: true } }
      );
    } catch (error) {
      throw error;
    }
  }

  async delete(id) {
    try {
      return await Notification.findByIdAndDelete(id);
    } catch (error) {
      throw error;
    }
  }

  async countUnread(userId) {
    try {
      return await Notification.countDocuments({ userId, isRead: false });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new NotificationRepository();


