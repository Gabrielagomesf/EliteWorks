const paymentRepository = require('../repositories/paymentRepository');
const notificationRepository = require('../repositories/notificationRepository');
const mercadoPagoService = require('../services/mercadoPagoService');
const Service = require('../models/Service');
const crypto = require('crypto');

class PaymentController {
  async create(req, res) {
    try {
      const { serviceId, method, amount } = req.body;
      const userId = req.user.userId;

      if (!serviceId || !amount) {
        return res.status(400).json({
          success: false,
          error: 'serviceId e amount são obrigatórios',
        });
      }

      const service = await Service.findById(serviceId)
        .populate('clientId')
        .populate('professionalId');

      if (!service) {
        return res.status(404).json({
          success: false,
          error: 'Serviço não encontrado',
        });
      }

      const isClient = service.clientId._id.toString() === userId.toString();
      const isProfessional = service.professionalId._id.toString() === userId.toString();

      if (!isClient && !isProfessional) {
        return res.status(403).json({
          success: false,
          error: 'Você não tem permissão para criar pagamento para este serviço',
        });
      }

      let pixQrCode = null;
      let pixCopyPaste = null;

      if (method === 'PIX') {
        const transactionId = crypto.randomBytes(16).toString('hex');
        pixCopyPaste = this._generatePixCopyPaste(serviceId, amount, transactionId);
        pixQrCode = this._generatePixQrCode(pixCopyPaste);
      }

      const payment = await paymentRepository.create({
        serviceId,
        clientId: service.clientId._id,
        professionalId: service.professionalId._id,
        amount,
        method: method || 'PIX',
        transactionId: method === 'PIX' ? crypto.randomBytes(16).toString('hex') : null,
        pixQrCode,
        pixCopyPaste,
      });

      await notificationRepository.create({
        userId: isClient ? service.professionalId._id : service.clientId._id,
        title: 'Novo pagamento',
        message: `Um pagamento de R$ ${amount.toFixed(2)} foi criado para o serviço: ${service.title}`,
        type: 'payment',
        relatedId: payment._id,
        data: { amount, method: method || 'PIX' },
      });

      res.status(201).json({
        success: true,
        payment: {
          id: payment._id.toString(),
          serviceId: payment.serviceId.toString(),
          clientId: payment.clientId.toString(),
          professionalId: payment.professionalId.toString(),
          amount: payment.amount,
          status: payment.status,
          method: payment.method,
          transactionId: payment.transactionId,
          pixQrCode: payment.pixQrCode,
          pixCopyPaste: payment.pixCopyPaste,
          createdAt: payment.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao criar pagamento: ' + error.message,
      });
    }
  }

  async getByServiceId(req, res) {
    try {
      const { serviceId } = req.params;
      const payments = await paymentRepository.findByServiceId(serviceId);

      res.json({
        success: true,
        payments: payments.map(p => ({
          id: p._id.toString(),
          serviceId: p.serviceId._id.toString(),
          serviceTitle: p.serviceId.title,
          clientId: p.clientId?._id?.toString(),
          clientName: p.clientId?.name,
          professionalId: p.professionalId?._id?.toString(),
          professionalName: p.professionalId?.name,
          amount: p.amount,
          status: p.status,
          method: p.method,
          transactionId: p.transactionId,
          pixQrCode: p.pixQrCode,
          pixCopyPaste: p.pixCopyPaste,
          paidAt: p.paidAt,
          createdAt: p.createdAt,
        })),
        total: payments.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar pagamentos: ' + error.message,
      });
    }
  }

  async getByClientId(req, res) {
    try {
      const userId = req.user.userId;
      const { limit = 50, skip = 0, status } = req.query;

      const payments = await paymentRepository.findByClientId(userId, {
        limit: parseInt(limit),
        skip: parseInt(skip),
        status,
      });

      const totalPaid = await paymentRepository.getTotalByClientId(userId, 'completed');

      res.json({
        success: true,
        payments: payments.map(p => ({
          id: p._id.toString(),
          serviceId: p.serviceId?._id?.toString(),
          serviceTitle: p.serviceId?.title,
          professionalId: p.professionalId?._id?.toString(),
          professionalName: p.professionalId?.name,
          amount: p.amount,
          status: p.status,
          method: p.method,
          transactionId: p.transactionId,
          paidAt: p.paidAt,
          createdAt: p.createdAt,
        })),
        totalPaid,
        total: payments.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar pagamentos: ' + error.message,
      });
    }
  }

  async getByProfessionalId(req, res) {
    try {
      const userId = req.user.userId;
      const { limit = 50, skip = 0, status } = req.query;

      const payments = await paymentRepository.findByProfessionalId(userId, {
        limit: parseInt(limit),
        skip: parseInt(skip),
        status,
      });

      const totalReceived = await paymentRepository.getTotalByProfessionalId(userId, 'completed');

      res.json({
        success: true,
        payments: payments.map(p => ({
          id: p._id.toString(),
          serviceId: p.serviceId?._id?.toString(),
          serviceTitle: p.serviceId?.title,
          clientId: p.clientId?._id?.toString(),
          clientName: p.clientId?.name,
          amount: p.amount,
          status: p.status,
          method: p.method,
          transactionId: p.transactionId,
          paidAt: p.paidAt,
          createdAt: p.createdAt,
        })),
        totalReceived,
        total: payments.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar pagamentos: ' + error.message,
      });
    }
  }

  async updateStatus(req, res) {
    try {
      const { id } = req.params;
      const { status, transactionId } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          error: 'status é obrigatório',
        });
      }

      const updates = { status };
      if (status === 'completed') {
        updates.paidAt = new Date();
      }
      if (transactionId) {
        updates.transactionId = transactionId;
      }

      const payment = await paymentRepository.update(id, updates);

      if (!payment) {
        return res.status(404).json({
          success: false,
          error: 'Pagamento não encontrado',
        });
      }

      if (status === 'completed') {
        await notificationRepository.create({
          userId: payment.professionalId._id,
          title: 'Pagamento confirmado',
          message: `O pagamento de R$ ${payment.amount.toFixed(2)} foi confirmado`,
          type: 'payment',
          relatedId: payment._id,
          data: { amount: payment.amount, method: payment.method },
        });

        await notificationRepository.create({
          userId: payment.clientId._id,
          title: 'Pagamento confirmado',
          message: `Seu pagamento de R$ ${payment.amount.toFixed(2)} foi confirmado`,
          type: 'payment',
          relatedId: payment._id,
          data: { amount: payment.amount, method: payment.method },
        });
      }

      res.json({
        success: true,
        payment: {
          id: payment._id.toString(),
          serviceId: payment.serviceId._id.toString(),
          clientId: payment.clientId._id.toString(),
          professionalId: payment.professionalId._id.toString(),
          amount: payment.amount,
          status: payment.status,
          method: payment.method,
          transactionId: payment.transactionId,
          paidAt: payment.paidAt,
          createdAt: payment.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao atualizar pagamento: ' + error.message,
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const payment = await paymentRepository.findById(id);

      if (!payment) {
        return res.status(404).json({
          success: false,
          error: 'Pagamento não encontrado',
        });
      }

      res.json({
        success: true,
        payment: {
          id: payment._id.toString(),
          serviceId: payment.serviceId._id.toString(),
          serviceTitle: payment.serviceId.title,
          clientId: payment.clientId?._id?.toString(),
          clientName: payment.clientId?.name,
          professionalId: payment.professionalId?._id?.toString(),
          professionalName: payment.professionalId?.name,
          amount: payment.amount,
          status: payment.status,
          method: payment.method,
          transactionId: payment.transactionId,
          pixQrCode: payment.pixQrCode,
          pixCopyPaste: payment.pixCopyPaste,
          paidAt: payment.paidAt,
          createdAt: payment.createdAt,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao buscar pagamento: ' + error.message,
      });
    }
  }

  async checkPaymentStatus(req, res) {
    try {
      const { id } = req.params;
      const payment = await paymentRepository.findById(id);

      if (!payment) {
        return res.status(404).json({
          success: false,
          error: 'Pagamento não encontrado',
        });
      }

      if (payment.transactionId) {
        const mpResult = await mercadoPagoService.getPayment(payment.transactionId);
        
        if (mpResult.success) {
          const mpStatus = mpResult.payment.status;
          let newStatus = payment.status;

          if (mpStatus === 'approved') {
            newStatus = 'completed';
          } else if (mpStatus === 'rejected' || mpStatus === 'cancelled') {
            newStatus = 'failed';
          } else if (mpStatus === 'refunded') {
            newStatus = 'refunded';
          }

          if (newStatus !== payment.status) {
            await paymentRepository.update(id, { status: newStatus });
            payment.status = newStatus;
          }
        }
      }

      res.json({
        success: true,
        payment: {
          id: payment._id.toString(),
          status: payment.status,
          transactionId: payment.transactionId,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao verificar status do pagamento: ' + error.message,
      });
    }
  }

  async createCardToken(req, res) {
    try {
      const { cardNumber, cardholderName, cardExpirationMonth, cardExpirationYear, securityCode, identificationType, identificationNumber } = req.body;

      if (!cardNumber || !cardholderName || !cardExpirationMonth || !cardExpirationYear || !securityCode) {
        return res.status(400).json({
          success: false,
          error: 'Dados do cartão incompletos',
        });
      }

      const result = await mercadoPagoService.createCardToken({
        cardNumber,
        cardholderName,
        cardExpirationMonth,
        cardExpirationYear,
        securityCode,
        identificationType: identificationType || 'CPF',
        identificationNumber: identificationNumber || '',
      });

      if (result.success) {
        res.json({
          success: true,
          token: result.token,
        });
      } else {
        res.status(400).json({
          success: false,
          error: result.error || 'Erro ao criar token do cartão',
        });
      }
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Erro ao criar token do cartão: ' + error.message,
      });
    }
  }

  _validateWebhookSignature(req) {
    // Valida a assinatura secreta do webhook do Mercado Pago
    const secret = process.env.MERCADOPAGO_WEBHOOK_SECRET;
    
    if (!secret) {
      console.warn('MERCADOPAGO_WEBHOOK_SECRET não configurado. Webhook não será validado.');
      return true; // Permite em desenvolvimento se não estiver configurado
    }

    const signature = req.headers['x-signature'] || req.headers['x-signature-id'];
    
    if (!signature) {
      console.error('Header x-signature não encontrado');
      return false;
    }

    try {
      // O Mercado Pago envia a assinatura no formato: sha256=hash ou apenas o hash
      let receivedHash = signature;
      if (signature.includes('=')) {
        const [algorithm, hash] = signature.split('=');
        if (algorithm !== 'sha256') {
          console.error('Algoritmo de assinatura não suportado:', algorithm);
          return false;
        }
        receivedHash = hash;
      }

      // Precisamos do body como string para calcular o hash
      // Se o body for Buffer (raw), converte para string, senão serializa o JSON
      let bodyString;
      if (Buffer.isBuffer(req.body)) {
        bodyString = req.body.toString('utf8');
      } else {
        bodyString = JSON.stringify(req.body);
      }
      
      // Parse do body se ainda não foi parseado
      if (Buffer.isBuffer(req.body)) {
        try {
          req.body = JSON.parse(bodyString);
        } catch (e) {
          // Ignora erro de parsing
        }
      }
      
      // Calcula o hash usando a assinatura secreta + body
      const calculatedHash = crypto
        .createHmac('sha256', secret)
        .update(bodyString)
        .digest('hex');

      // Compara os hashes
      const isValid = calculatedHash === receivedHash;
      
      if (!isValid) {
        console.error('Assinatura do webhook inválida. Recebido:', receivedHash.substring(0, 10) + '...', 'Calculado:', calculatedHash.substring(0, 10) + '...');
      }
      
      return isValid;
    } catch (error) {
      console.error('Erro ao validar assinatura do webhook:', error);
      return false;
    }
  }

  async webhook(req, res) {
    try {
      // Valida a assinatura secreta
      if (!this._validateWebhookSignature(req)) {
        return res.status(401).json({
          success: false,
          error: 'Assinatura do webhook inválida',
        });
      }

      const { type, data } = req.body;

      if (type === 'payment') {
        const paymentId = data.id;
        
        const mpResult = await mercadoPagoService.getPayment(paymentId);
        
        if (mpResult.success) {
          const mpPayment = mpResult.payment;
          const mpStatus = mpPayment.status;
          
          const payment = await paymentRepository.findByTransactionId(paymentId.toString());
          
          if (payment) {
            let newStatus = payment.status;
            const updates = {};

            if (mpStatus === 'approved') {
              newStatus = 'completed';
              updates.paidAt = new Date();
            } else if (mpStatus === 'rejected' || mpStatus === 'cancelled') {
              newStatus = 'failed';
            } else if (mpStatus === 'refunded') {
              newStatus = 'refunded';
            }

            if (newStatus !== payment.status) {
              updates.status = newStatus;
              await paymentRepository.update(payment._id.toString(), updates);

              if (newStatus === 'completed') {
                await notificationRepository.create({
                  userId: payment.professionalId._id,
                  title: 'Pagamento confirmado',
                  message: `O pagamento de R$ ${payment.amount.toFixed(2)} foi confirmado`,
                  type: 'payment',
                  relatedId: payment._id,
                  data: { amount: payment.amount, method: payment.method },
                });

                await notificationRepository.create({
                  userId: payment.clientId._id,
                  title: 'Pagamento confirmado',
                  message: `Seu pagamento de R$ ${payment.amount.toFixed(2)} foi confirmado`,
                  type: 'payment',
                  relatedId: payment._id,
                  data: { amount: payment.amount, method: payment.method },
                });
              }
            }
          }
        }
      }

      res.status(200).json({ received: true });
    } catch (error) {
      console.error('Erro no webhook do Mercado Pago:', error);
      res.status(500).json({
        success: false,
        error: 'Erro ao processar webhook: ' + error.message,
      });
    }
  }
}

module.exports = new PaymentController();

