const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authenticateToken = require('../middleware/auth');

// Criar notificação (pode ser usado por admin ou sistema)
router.post('/', authenticateToken, notificationController.create.bind(notificationController));
// Buscar notificações do usuário autenticado
router.get('/', authenticateToken, notificationController.getNotifications.bind(notificationController));
// Contar notificações não lidas
router.get('/unread-count', authenticateToken, notificationController.getUnreadCount.bind(notificationController));
// Marcar notificação como lida
router.put('/:id/read', authenticateToken, notificationController.markAsRead.bind(notificationController));
// Marcar todas como lidas
router.put('/read-all', authenticateToken, notificationController.markAllAsRead.bind(notificationController));
// Deletar notificação
router.delete('/:id', authenticateToken, notificationController.delete.bind(notificationController));

module.exports = router;


