const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const bcrypt = require('bcrypt');
const User = require('../models/User');

exports.register = async (req, res) => {
    const { username, password } = req.body;

    try {
        // Basic validation
        if (!username || !password) {
            console.warn('Username or password missing in request body.');
        }

        // Hash the password asynchronously
        const passwordHash = await bcrypt.hash(password, 10); // using async version

        // Create and save the new user
        const newUser = new User({ username, passwordHash });
        await newUser.save();

        // Respond to client
        res.status(201).json({ message: 'User registered successfully' });

    } catch (err) {
        console.error('Error during user registration:', err.message);
        res.status(500).json({ error: err.message });
    }
};


exports.login = async (req, res) => {
    const { username, password } = req.body;

    try {
        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ message: 'User not found' });

        const isMatch = bcrypt.compareSync(password, user.passwordHash);
        if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.json({ token });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getUsername = async (req, res) => {
    const userId = req.user.id; // Extract user ID from JWT payload
    
    try {
        console.log(userId)
        const user = await User.findById(userId);
        
        if (!user) return res.status(404).json({ message: 'User not found' });

        res.json({ username: user.username });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
