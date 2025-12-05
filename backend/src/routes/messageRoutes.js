const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, messageController.sendMessage.bind(messageController));
router.get('/conversations', authenticateToken, messageController.getConversations.bind(messageController));
router.get('/conversation/:otherUserId', authenticateToken, messageController.getConversation.bind(messageController));
router.put('/read', authenticateToken, messageController.markAsRead.bind(messageController));
router.put('/conversation/:otherUserId/read', authenticateToken, messageController.markConversationAsRead.bind(messageController));
router.get('/unread-count', authenticateToken, messageController.getUnreadCount.bind(messageController));
router.delete('/:id', authenticateToken, messageController.deleteMessage.bind(messageController));

module.exports = router;


