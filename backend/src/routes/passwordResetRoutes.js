const express = require('express');
const router = express.Router();
const passwordResetController = require('../controllers/passwordResetController');

router.post('/request', passwordResetController.requestReset.bind(passwordResetController));
router.post('/validate', passwordResetController.validateToken.bind(passwordResetController));
router.post('/reset', passwordResetController.resetPassword.bind(passwordResetController));

module.exports = router;


