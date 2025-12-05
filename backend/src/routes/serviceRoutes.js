const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, serviceController.create);
router.get('/:id', authenticateToken, serviceController.getById);
router.get('/client/:clientId', authenticateToken, serviceController.getByClientId);
router.get('/professional/:professionalId', authenticateToken, serviceController.getByProfessionalId);
router.put('/:id', authenticateToken, serviceController.update);
router.delete('/:id', authenticateToken, serviceController.delete);

module.exports = router;


