const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, paymentController.create.bind(paymentController));
router.post('/card-token', authenticateToken, paymentController.createCardToken.bind(paymentController));
router.post('/webhook', paymentController.webhook.bind(paymentController));
router.get('/service/:serviceId', authenticateToken, paymentController.getByServiceId.bind(paymentController));
router.get('/client', authenticateToken, paymentController.getByClientId.bind(paymentController));
router.get('/professional', authenticateToken, paymentController.getByProfessionalId.bind(paymentController));
router.get('/:id', authenticateToken, paymentController.getById.bind(paymentController));
router.get('/:id/status', authenticateToken, paymentController.checkPaymentStatus.bind(paymentController));
router.put('/:id/status', authenticateToken, paymentController.updateStatus.bind(paymentController));

module.exports = router;

