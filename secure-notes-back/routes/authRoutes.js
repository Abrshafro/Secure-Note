const express = require('express');
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
const { register, login, getUsername} = require('../controllers/authController');
const router = express.Router();

router.post('/login', login);
router.get('/username', authMiddleware, getUsername);
router.post('/register', register);

module.exports = router;
