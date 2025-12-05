const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticate } = require('../middleware/auth');

router.get('/profile', authenticate, userController.getProfile.bind(userController));
router.put('/profile', authenticate, userController.updateProfile.bind(userController));
router.put('/change-password', authenticate, userController.changePassword.bind(userController));
router.delete('/account', authenticate, userController.deleteAccount.bind(userController));

module.exports = router;


