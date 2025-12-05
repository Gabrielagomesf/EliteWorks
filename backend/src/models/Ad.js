const mongoose = require('mongoose');

const adSchema = new mongoose.Schema({
  professionalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Professional', required: true },
  title: { type: String, required: true },
  description: { type: String },
  category: { type: String, required: true },
  price: { type: Number, default: 0 },
  images: [{ type: String }],
  isActive: { type: Boolean, default: true },
  expiresAt: { type: Date },
  details: { type: Map, of: mongoose.Schema.Types.Mixed },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

adSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Índice para buscar anúncios ativos
adSchema.index({ professionalId: 1, isActive: 1, createdAt: -1 });

module.exports = mongoose.model('Ad', adSchema);


