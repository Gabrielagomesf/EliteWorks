const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, reviewController.create.bind(reviewController));
router.get('/professional/:professionalId', reviewController.getByProfessionalId.bind(reviewController));
router.get('/:id', reviewController.getById.bind(reviewController));
router.put('/:id', authenticateToken, reviewController.update.bind(reviewController));
router.delete('/:id', authenticateToken, reviewController.delete.bind(reviewController));

module.exports = router;


