"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const generative_ai_1 = require("@google/generative-ai");
const app = (0, express_1.default)();
// Security middlewares
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)({
    origin: '*', // For Flutter mobile clients, '*' is acceptable since mobile apps don't have a web origin. If deploying to web, restrict this.
    methods: ['GET', 'POST', 'OPTIONS'],
}));
app.use(express_1.default.json({ limit: '1mb' })); // Restrict payload size
// Health check endpoint for Render
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});
// Check-ins mock endpoints
app.post('/api/v1/check-ins', (req, res) => {
    res.status(201).json({
        check_in_id: `checkin_${Date.now()}`,
        timestamp: req.body?.timestamp || new Date().toISOString(),
        status: "submitted"
    });
});
app.get('/api/v1/check-ins', (req, res) => {
    res.status(200).json({
        items: [
            {
                check_in_id: "checkin_mock",
                timestamp: new Date().toISOString(),
                mood: "okay",
                energy: 6,
                fatigue: 3,
                stress: 4,
                symptoms: { headache: 2 }
            }
        ]
    });
});
// Chat endpoint
app.post('/api/v1/trace/chat', async (req, res) => {
    const apiKey = process.env.GEMINI_API_KEY;
    const userMessage = req.body?.message;
    if (!userMessage || typeof userMessage !== 'string' || userMessage.trim().length === 0) {
        return res.status(400).json({ error: 'Message is required' });
    }
    if (userMessage.length > 1000) {
        return res.status(400).json({ error: 'Message too long' });
    }
    if (!apiKey) {
        return res.status(200).json({
            response: `[Offline Mode] I received: ${userMessage}`,
            suggested_actions: ["Provide API Key"],
            safety_notice: "Offline mock response.",
            generated_at: new Date().toISOString()
        });
    }
    try {
        const genAI = new generative_ai_1.GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
        const prompt = `
You are TRACE, a supportive recovery assistant for a user tracking their daily energy and fatigue.
Safety rule: DO NOT provide medical advice or diagnoses. 
Use phrases like: "Your recent pattern suggests..." or "Based on your recent data...".
If symptoms are concerning, encourage speaking with a healthcare professional.

User says: "${userMessage}"
Reply concisely and warmly.
`;
        const result = await model.generateContent(prompt);
        const text = result.response.text();
        return res.status(200).json({
            response: text,
            suggested_actions: ["Adjust my day", "Tell me more"],
            safety_notice: "This guidance is not a diagnosis and should not be treated as medical clearance.",
            generated_at: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Gemini Error:', error);
        return res.status(500).json({ error: 'Failed to generate response' });
    }
});
// 404 Handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});
// Start Server
const PORT = process.env.PORT || 8080;
const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server listening on port ${PORT}`);
});
// Graceful shutdown for Render
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        process.exit(0);
    });
});
