require('dotenv').config({ path: '../.env' }); // Load from parent .env
const mongoose = require('mongoose');
const { Server } = require('socket.io');
const http = require('http');

// 1. Setup Server
const PORT = 3000;
const server = http.createServer();
const io = new Server(server, {
    cors: {
        origin: "*", // Allow all origins for testing
    }
});

// 2. Connect to MongoDB
const MONGODB_URI = process.env.MONGODB_URI;
if (!MONGODB_URI) {
    console.error("❌ MONGODB_URI not found in environment variables!");
    process.exit(1);
}

mongoose.connect(MONGODB_URI)
    .then(() => console.log("✅ Connected to MongoDB"))
    .catch(err => console.error("❌ MongoDB connection error:", err));

// 3. Define Message Schema
const messageSchema = new mongoose.Schema({
    content: String,
    senderId: String,
    timestamp: { type: Date, default: Date.now },
    isRead: { type: Boolean, default: false }
});

const Message = mongoose.model('Message', messageSchema);

// 4. Socket.io Logic
io.on('connection', (socket) => {
    console.log(`🔌 New client connected: ${socket.id}, UserID: ${socket.handshake.query.userId}`);

    socket.on('send_message', async (data) => {
        console.log('📩 Received message:', data);

        try {
            // Save to MongoDB
            const newMessage = new Message({
                content: data.content,
                senderId: data.senderId,
                timestamp: data.timestamp || new Date()
            });

            const savedMessage = await newMessage.save();
            console.log('💾 Message saved to DB:', savedMessage._id);

            // Broadcast to all clients (including sender)
            // client-side logic should handle not duplicating if it already optimistically added it,
            // or we can broadcast to everyone EXCEPT sender using socket.broadcast.emit
            // For simplicity, we emit to everyone so other devices see it too.
            io.emit('receive_message', {
                _id: savedMessage._id,
                content: savedMessage.content,
                senderId: savedMessage.senderId,
                timestamp: savedMessage.timestamp,
                isRead: savedMessage.isRead
            });
            console.log('📡 Broadcasted receive_message');

        } catch (err) {
            console.error('❌ Error saving message:', err);
        }
    });

    socket.on('disconnect', () => {
        console.log(`❌ Client disconnected: ${socket.id}`);
    });
});

server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});
