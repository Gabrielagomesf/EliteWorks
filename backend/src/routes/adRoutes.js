const express = require('express');
const router = express.Router();
const adController = require('../controllers/adController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, adController.create.bind(adController));
router.get('/active', adController.getActiveAds.bind(adController));
router.get('/professional/:professionalId', adController.getByProfessionalId.bind(adController));
router.get('/:id', adController.getById.bind(adController));
router.put('/:id', authenticateToken, adController.update.bind(adController));
router.delete('/:id', authenticateToken, adController.delete.bind(adController));

module.exports = router;


