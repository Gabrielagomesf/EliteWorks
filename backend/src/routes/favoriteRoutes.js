const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favoriteController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, favoriteController.addFavorite.bind(favoriteController));
router.get('/', authenticateToken, favoriteController.getFavorites.bind(favoriteController));
router.get('/:professionalId', authenticateToken, favoriteController.checkFavorite.bind(favoriteController));
router.delete('/:professionalId', authenticateToken, favoriteController.removeFavorite.bind(favoriteController));

module.exports = router;


