const mongoose = require('mongoose');
require('dotenv').config();

let isConnected = false;

const connectDB = async () => {
  if (isConnected && mongoose.connection.readyState === 1) {
    return;
  }

  try {
    await mongoose.connect(process.env.MONGODB_CONNECTION_STRING);
    
    isConnected = true;
    console.log('MongoDB conectado com sucesso');
  } catch (error) {
    console.error('Erro ao conectar MongoDB:', error);
    isConnected = false;
    throw error;
  }
};

const disconnectDB = async () => {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
    isConnected = false;
    console.log('MongoDB desconectado');
  }
};

module.exports = { connectDB, disconnectDB };


