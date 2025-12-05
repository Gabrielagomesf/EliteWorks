const express = require('express');
const router = express.Router();
const professionalController = require('../controllers/professionalController');

router.get('/search', professionalController.search.bind(professionalController));
router.get('/count', professionalController.count.bind(professionalController));
router.get('/featured', professionalController.getFeatured.bind(professionalController));
router.get('/:id', professionalController.getById.bind(professionalController));

module.exports = router;

