const mercadopago = require('mercadopago');

class MercadoPagoService {
  constructor() {
    this.initialized = false;
  }

  initialize() {
    if (this.initialized) return;

    if (!process.env.MERCADOPAGO_ACCESS_TOKEN) {
      throw new Error('MERCADOPAGO_ACCESS_TOKEN não configurado no .env');
    }

    mercadopago.configure({
      access_token: process.env.MERCADOPAGO_ACCESS_TOKEN,
    });

    this.initialized = true;
  }

  async createPayment(paymentData) {
    this.initialize();

    const { amount, description, payerEmail, payerName, paymentMethodId, installments, token } = paymentData;

    const paymentDataMP = {
      transaction_amount: parseFloat(amount),
      description: description || 'Pagamento EliteWorks',
      payment_method_id: paymentMethodId,
      payer: {
        email: payerEmail,
        identification: {
          type: 'CPF',
          number: '',
        },
        name: payerName,
      },
      installments: installments || 1,
      token: token,
      statement_descriptor: 'ELITEWORKS',
      external_reference: paymentData.externalReference || null,
      notification_url: process.env.MERCADOPAGO_WEBHOOK_URL || null,
    };

    try {
      const response = await mercadopago.payment.save(paymentDataMP);
      return {
        success: true,
        payment: {
          id: response.body.id,
          status: response.body.status,
          status_detail: response.body.status_detail,
          transaction_amount: response.body.transaction_amount,
          payment_method_id: response.body.payment_method_id,
          payment_type_id: response.body.payment_type_id,
          date_created: response.body.date_created,
          date_approved: response.body.date_approved,
        },
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Erro ao processar pagamento',
        details: error.cause || null,
      };
    }
  }

  async createPixPayment(paymentData) {
    this.initialize();

    const { amount, description, payerEmail, payerName, externalReference } = paymentData;

    const paymentDataMP = {
      transaction_amount: parseFloat(amount),
      description: description || 'Pagamento EliteWorks',
      payment_method_id: 'pix',
      payer: {
        email: payerEmail,
        name: payerName,
      },
      external_reference: externalReference || null,
      notification_url: process.env.MERCADOPAGO_WEBHOOK_URL || null,
    };

    try {
      const response = await mercadopago.payment.save(paymentDataMP);
      
      let qrCode = null;
      let qrCodeBase64 = null;
      let copyPaste = null;

      if (response.body.point_of_interaction && response.body.point_of_interaction.transaction_data) {
        qrCode = response.body.point_of_interaction.transaction_data.qr_code;
        qrCodeBase64 = response.body.point_of_interaction.transaction_data.qr_code_base64;
        copyPaste = response.body.point_of_interaction.transaction_data.qr_code;
      }

      return {
        success: true,
        payment: {
          id: response.body.id,
          status: response.body.status,
          status_detail: response.body.status_detail,
          transaction_amount: response.body.transaction_amount,
          payment_method_id: response.body.payment_method_id,
          date_created: response.body.date_created,
          qr_code: qrCode,
          qr_code_base64: qrCodeBase64,
          copy_paste: copyPaste,
        },
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Erro ao processar pagamento PIX',
        details: error.cause || null,
      };
    }
  }

  async getPayment(paymentId) {
    this.initialize();

    try {
      const response = await mercadopago.payment.findById(paymentId);
      return {
        success: true,
        payment: {
          id: response.body.id,
          status: response.body.status,
          status_detail: response.body.status_detail,
          transaction_amount: response.body.transaction_amount,
          payment_method_id: response.body.payment_method_id,
          payment_type_id: response.body.payment_type_id,
          date_created: response.body.date_created,
          date_approved: response.body.date_approved,
        },
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Erro ao buscar pagamento',
      };
    }
  }

  async createCardToken(cardData) {
    this.initialize();

    const { cardNumber, cardholderName, cardExpirationMonth, cardExpirationYear, securityCode, identificationType, identificationNumber } = cardData;

    const tokenData = {
      card_number: cardNumber,
      cardholder: {
        name: cardholderName,
        identification: {
          type: identificationType || 'CPF',
          number: identificationNumber || '',
        },
      },
      card_expiration_month: cardExpirationMonth,
      card_expiration_year: cardExpirationYear,
      security_code: securityCode,
    };

    try {
      const response = await mercadopago.cardtoken.create(tokenData);
      return {
        success: true,
        token: response.id,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message || 'Erro ao criar token do cartão',
        details: error.cause || null,
      };
    }
  }
}

module.exports = new MercadoPagoService();


