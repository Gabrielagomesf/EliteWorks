const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  serviceId: { type: mongoose.Schema.Types.ObjectId, ref: 'Service', required: true },
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  professionalId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded', 'cancelled'],
    default: 'pending'
  },
  method: {
    type: String,
    enum: ['PIX', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto', 'Transferência'],
    default: 'PIX'
  },
  transactionId: { type: String },
  pixQrCode: { type: String },
  pixCopyPaste: { type: String },
  paidAt: { type: Date },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

paymentSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

paymentSchema.index({ serviceId: 1 });
paymentSchema.index({ clientId: 1, createdAt: -1 });
paymentSchema.index({ professionalId: 1, createdAt: -1 });

module.exports = mongoose.model('Payment', paymentSchema);


