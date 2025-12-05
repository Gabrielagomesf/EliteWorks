const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, serviceController.create.bind(serviceController));
router.get('/:id', authenticateToken, serviceController.getById.bind(serviceController));
router.get('/client/:clientId', authenticateToken, serviceController.getByClientId.bind(serviceController));
router.get('/professional/:professionalId', authenticateToken, serviceController.getByProfessionalId.bind(serviceController));
router.put('/:id', authenticateToken, serviceController.update.bind(serviceController));
router.delete('/:id', authenticateToken, serviceController.delete.bind(serviceController));

module.exports = router;


