const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  phone: { type: String },
  cpf: { type: String },
  birthDate: { type: String },
  gender: { type: String },
  userType: { type: String, required: true, enum: ['cliente', 'profissional'] },
  profileImage: { type: String },
  address: {
    zipCode: String,
    address: String,
    number: String,
    complement: String,
    neighborhood: String,
    city: String,
    state: String,
  },
  bankData: {
    bankCode: String,
    accountNumber: String,
    accountDigit: String,
    agency: String,
    pixKey: String,
    pixKeyType: String,
  },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);


