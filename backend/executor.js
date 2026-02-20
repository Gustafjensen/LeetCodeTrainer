const { execFile } = require('child_process');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const TIMEOUT_MS = 10000;
const EXEC_TIMEOUT_SECS = 5;
const TEMP_BASE = '/tmp/leetcode';

async function executeCode(sourceCode, problem) {
    const runId = uuidv4();
    const tempDir = path.join(TEMP_BASE, runId);

    try {
        fs.mkdirSync(tempDir, { recursive: true });

        const testData = {
            functionName: problem.functionName,
            testCases: problem.testCases,
            compareFunction: problem.compareFunction || 'exact'
        };

        const harnessTemplate = fs.readFileSync(
            path.join(__dirname, 'runner', 'run.py'), 'utf-8'
        );

        const testDataJson = JSON.stringify(testData)
            .replace(/\\/g, '\\\\')
            .replace(/'/g, "\\'");

        const script = harnessTemplate
            .replace('__LEETCODE_USER_CODE_INJECT_POINT__', sourceCode)
            .replace('__LEETCODE_TEST_DATA_INJECT_POINT__', testDataJson);

        const scriptPath = path.join(tempDir, 'solution.py');
        fs.writeFileSync(scriptPath, script);
        fs.chmodSync(scriptPath, 0o644);

        const result = await runAsSubprocess(scriptPath);
        return result;
    } finally {
        try {
            fs.rmSync(tempDir, { recursive: true, force: true });
        } catch (e) {
            console.error('Cleanup error:', e.message);
        }
    }
}

function runAsSubprocess(scriptPath) {
    return new Promise((resolve) => {
        const args = [
            String(EXEC_TIMEOUT_SECS),
            'python3', '-I', '-u',
            scriptPath
        ];

        execFile('timeout', args, {
            timeout: TIMEOUT_MS,
            maxBuffer: 1024 * 1024,
            uid: 1000,
            gid: 1000,
            cwd: path.dirname(scriptPath),
            env: {
                PATH: '/usr/local/bin:/usr/bin:/bin',
                HOME: '/home/runner',
                PYTHONDONTWRITEBYTECODE: '1',
                PYTHONHASHSEED: '0',
            }
        }, (error, stdout, stderr) => {
            if (error) {
                if (error.killed || error.signal === 'SIGTERM' || error.code === 124) {
                    return resolve({
                        compilationSuccess: false,
                        runtimeError: 'Time Limit Exceeded (5 seconds)',
                        testResults: [],
                        overallStatus: 'error',
                        runtime: '5000ms',
                        memory: '0MB'
                    });
                }

                if (stderr) {
                    const lines = stderr.trim().split('\n');
                    const errorMsg = lines.slice(-3).join('\n');
                    return resolve({
                        compilationSuccess: false,
                        runtimeError: errorMsg,
                        testResults: [],
                        overallStatus: 'error',
                        runtime: '0ms',
                        memory: '0MB'
                    });
                }

                return resolve({
                    compilationSuccess: false,
                    runtimeError: `Execution failed: ${error.message}`,
                    testResults: [],
                    overallStatus: 'error',
                    runtime: '0ms',
                    memory: '0MB'
                });
            }

            try {
                const result = JSON.parse(stdout.trim());
                resolve(result);
            } catch (parseError) {
                resolve({
                    compilationSuccess: false,
                    runtimeError: `Output parsing error. Your code may have printed unexpected output.\nRaw output: ${stdout.substring(0, 500)}`,
                    testResults: [],
                    overallStatus: 'error',
                    runtime: '0ms',
                    memory: '0MB'
                });
            }
        });
    });
}

module.exports = { executeCode };
