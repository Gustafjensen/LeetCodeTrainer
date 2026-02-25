const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const { executeCode } = require('./executor');
const problems = require('./problems');

const app = express();
const PORT = process.env.PORT || 8080;
const API_KEY = process.env.API_KEY;

app.set('trust proxy', true);
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// API key authentication middleware
function requireApiKey(req, res, next) {
    if (!API_KEY) return next(); // Skip if no key configured (local dev)
    const provided = req.headers['x-api-key'];
    if (provided !== API_KEY) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    next();
}

// Rate limit on /execute: 30 requests per minute per IP
const executeLimiter = rateLimit({
    windowMs: 60 * 1000,
    max: 30,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        compilationSuccess: false,
        runtimeError: 'Too many requests. Please wait a moment and try again.',
        testResults: [],
        overallStatus: 'error',
        runtime: '0ms',
        memory: '0MB'
    }
});

app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/problems', requireApiKey, (req, res) => {
    const list = Object.keys(problems).map(id => ({
        id,
        title: problems[id].title,
        testCaseCount: problems[id].testCases.length
    }));
    res.json(list);
});

app.post('/execute', requireApiKey, executeLimiter, async (req, res) => {
    const { problemId, language, sourceCode } = req.body;

    if (!problemId || !language || !sourceCode) {
        return res.status(400).json({
            compilationSuccess: false,
            runtimeError: 'Missing required fields: problemId, language, sourceCode',
            testResults: [],
            overallStatus: 'error',
            runtime: '0ms',
            memory: '0MB'
        });
    }

    if (language !== 'python') {
        return res.status(400).json({
            compilationSuccess: false,
            runtimeError: `Unsupported language: ${language}. Only "python" is supported.`,
            testResults: [],
            overallStatus: 'error',
            runtime: '0ms',
            memory: '0MB'
        });
    }

    const problem = problems[problemId];
    if (!problem) {
        return res.status(404).json({
            compilationSuccess: false,
            runtimeError: `Problem not found: ${problemId}`,
            testResults: [],
            overallStatus: 'error',
            runtime: '0ms',
            memory: '0MB'
        });
    }

    try {
        const result = await executeCode(sourceCode, problem);
        res.json(result);
    } catch (error) {
        console.error('Execution error:', error);
        res.status(500).json({
            compilationSuccess: false,
            runtimeError: 'Internal server error during execution',
            testResults: [],
            overallStatus: 'error',
            runtime: '0ms',
            memory: '0MB'
        });
    }
});

app.listen(PORT, () => {
    console.log(`LeetCode Trainer backend running on port ${PORT}`);
});
