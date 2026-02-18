const { execFile } = require('child_process');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const os = require('os');

const TIMEOUT_MS = 10000;
const SANDBOX_IMAGE = 'leetcode-python-sandbox';

async function executeCode(sourceCode, problem) {
    const runId = uuidv4();
    const tempDir = path.join(os.tmpdir(), `leetcode-${runId}`);

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

        const result = await runInDocker(scriptPath, tempDir);
        return result;
    } finally {
        try {
            fs.rmSync(tempDir, { recursive: true, force: true });
        } catch (e) {
            console.error('Cleanup error:', e.message);
        }
    }
}

function runInDocker(scriptPath, tempDir) {
    return new Promise((resolve) => {
        const args = [
            'run',
            '--rm',
            '--network=none',
            '--memory=128m',
            '--cpus=0.5',
            '--read-only',
            '--tmpfs', '/tmp:size=10m',
            '--user', '1000:1000',
            '-v', `${tempDir}/solution.py:/sandbox/solution.py:ro`,
            SANDBOX_IMAGE,
            'timeout', '5', 'python3', '/sandbox/solution.py'
        ];

        execFile('docker', args, {
            timeout: TIMEOUT_MS,
            maxBuffer: 1024 * 1024
        }, (error, stdout, stderr) => {
            if (error) {
                if (error.killed || error.signal === 'SIGTERM') {
                    return resolve({
                        compilationSuccess: false,
                        runtimeError: 'Time Limit Exceeded (5 seconds)',
                        testResults: [],
                        overallStatus: 'error',
                        runtime: '5000ms',
                        memory: '0MB'
                    });
                }

                if (error.code === 124) {
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
