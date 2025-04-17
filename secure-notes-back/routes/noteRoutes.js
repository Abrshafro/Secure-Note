const express = require('express');
const { addNote, updateNote, deleteNote, getNotes } = require('../controllers/noteController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/add', authMiddleware, addNote); // Add a new note
router.put('/:id', authMiddleware, updateNote); // Update an existing note
router.delete('/:id', authMiddleware, deleteNote); // Delete a note
router.get('/', authMiddleware, getNotes); // Get all notes


module.exports = router;
