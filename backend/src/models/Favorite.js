const mongoose = require('mongoose');

const favoriteSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  professionalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Professional', required: true },
  createdAt: { type: Date, default: Date.now },
});

// Índice único para evitar duplicatas
favoriteSchema.index({ userId: 1, professionalId: 1 }, { unique: true });

module.exports = mongoose.model('Favorite', favoriteSchema);


