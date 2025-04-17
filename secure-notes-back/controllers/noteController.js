const Note = require('../models/Note');
const Blowfish = require('blowfish');

const bf = new Blowfish(process.env.SECRET_KEY);

exports.addNote = async (req, res) => {
    const { content, title } = req.body; // Get the raw note and title from the request body
    const userId = req.user.id;

    try {
        // Encrypt the note using Blowfish and encode it in Base64
        const encryptedNote = bf.encrypt(content);

        const newNote = new Note({ userId, title, encryptedNote });
        await newNote.save();

        res.status(201).json({ message: 'Note added successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.updateNote = async (req, res) => {
    const { id } = req.params; // Note ID from the request parameters
    const { content, title } = req.body; // Updated note and title
    const userId = req.user.id;

    try {
        // Find the note by ID and verify ownership
        const existingNote = await Note.findOne({ _id: id, userId });
        if (!existingNote) {
            return res.status(404).json({ message: 'Note not found or not authorized' });
        }

        // Encrypt the updated note using Blowfish and encode it in Base64
        const encryptedNote = bf.encrypt(content);

        // Update the note's title and content
        existingNote.title = title;
        existingNote.encryptedNote = encryptedNote;

        await existingNote.save();

        res.status(200).json({ message: 'Note updated successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.deleteNote = async (req, res) => {
    const { id } = req.params; // Note ID from the request parameters
    const userId = req.user.id;

    try {
        // Find the note by ID and verify ownership
        const note = await Note.findOneAndDelete({ _id: id, userId });
        if (!note) {
            return res.status(404).json({ message: 'Note not found or not authorized' });
        }

        res.status(200).json({ message: 'Note deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.getNotes = async (req, res) => {
    const userId = req.user.id;

    try {
        // Fetch notes from the database
        const notes = await Note.find({ userId });

        // Decrypt each note before sending it to the user
        const decryptedNotes = notes.map(note => {
            

            // const encryptedBuffer = Buffer.from(note.encryptedNote, 'base64'); // Convert Base64 string back to Buffer
            // console.log(`Decrypted Note: ${encryptedBuffer}`);
            // const decryptedNote = bf.decrypt(encryptedBuffer).toString(); // Decrypt the Buffer and convert to string
            // console.log(`Decrypted Note: ${decryptedNote}`);
            const decryptedNote = bf.decrypt(note.encryptedNote).toString(); // Decrypt the Buffer and convert to string
            return {
                id: note._id,
                userId: note.userId,
                title:note.title,
                content: decryptedNote, // Add decrypted note here
                // createdAt: note.createdAt,
            };
        });

        res.json(decryptedNotes);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


