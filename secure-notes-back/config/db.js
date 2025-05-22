const mongoose = require('mongoose');
require('dotenv').config(); // Load environment variables from .env file

/**
 * Establishes a connection to the MongoDB database using Mongoose.
 */
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('✅ MongoDB connected successfully');
    } catch (err) {
        console.error('❌ MongoDB connection error:', err.message);
        process.exit(1); // Exit process with failure
    }
};

module.exports = connectDB;

