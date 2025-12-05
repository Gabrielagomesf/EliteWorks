const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  professionalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Professional', required: true },
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service' },
  rating: { type: Number, required: true, min: 1, max: 5 },
  comment: { type: String },
  createdAt: { type: Date, default: Date.now },
});

// Índice para buscar reviews de um profissional
reviewSchema.index({ professionalId: 1, createdAt: -1 });

// Índice único para evitar múltiplas reviews do mesmo cliente para o mesmo serviço
reviewSchema.index({ serviceId: 1, clientId: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model('Review', reviewSchema);


