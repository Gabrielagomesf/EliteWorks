const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { 
    type: String, 
    enum: ['proposal', 'service', 'message', 'review', 'payment', 'reminder', 'info'],
    default: 'info'
  },
  isRead: { type: Boolean, default: false },
  relatedId: { type: mongoose.Schema.Types.ObjectId }, // ID do serviço, mensagem, etc.
  data: { type: Map, of: mongoose.Schema.Types.Mixed }, // Dados adicionais
  createdAt: { type: Date, default: Date.now },
});

// Índice para buscar notificações não lidas rapidamente
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);


