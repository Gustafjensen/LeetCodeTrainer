import json
import sys
import time
import copy
import traceback
import socket as _socket

# === SECURITY: Redirect stdout so user print() goes to stderr ===
_real_stdout = sys.stdout
sys.stdout = sys.stderr

# === SECURITY: Block network access (must happen before import blocking) ===
_orig_socket = _socket.socket
def _blocked_socket(*args, **kwargs):
    raise OSError("Network access is disabled")
_socket.socket = _blocked_socket

# === SECURITY: Block file access outside temp directory ===
_original_open = open
def _restricted_open(file, *args, **kwargs):
    file_str = str(file)
    if not file_str.startswith('/tmp/leetcode/'):
        raise PermissionError("File access is not permitted in this environment")
    return _original_open(file, *args, **kwargs)
try:
    __builtins__.open = _restricted_open
except (AttributeError, TypeError):
    import builtins
    builtins.open = _restricted_open

# === SECURITY: Block dangerous module imports (after all harness imports) ===
_BLOCKED_MODULES = frozenset([
    'os', 'subprocess', 'shutil', 'signal', 'ctypes',
    'socket', 'http', 'urllib', 'requests',
    'multiprocessing', 'threading', '_thread',
    'pathlib', 'tempfile', 'glob', 'importlib',
    'code', 'codeop', 'compileall', 'py_compile',
    'ensurepip', 'pip', 'venv', 'site', 'sysconfig',
    'webbrowser', 'antigravity', 'turtle', 'tkinter',
    'resource', 'pty', 'fcntl', 'termios', 'mmap',
    'pickle', 'shelve', 'marshal',
])
_original_import = __builtins__.__import__ if hasattr(__builtins__, '__import__') else __import__
def _restricted_import(name, *args, **kwargs):
    top = name.split('.')[0]
    if top in _BLOCKED_MODULES:
        raise ImportError(f"Module '{name}' is not available in this environment")
    return _original_import(name, *args, **kwargs)
if hasattr(__builtins__, '__import__'):
    __builtins__.__import__ = _restricted_import
else:
    import builtins as _builtins
    _builtins.__import__ = _restricted_import

# === USER CODE ===

__LEETCODE_USER_CODE_INJECT_POINT__

# === TEST HARNESS ===

test_data = json.loads('__LEETCODE_TEST_DATA_INJECT_POINT__')

function_name = test_data['functionName']
test_cases = test_data['testCases']
compare_mode = test_data.get('compareFunction', 'exact')

results = []
start_time = time.time()

try:
    func = globals()[function_name]
except KeyError:
    output = {
        'compilationSuccess': False,
        'runtimeError': f"Function '{function_name}' not defined. Make sure your function is named exactly '{function_name}'.",
        'testResults': [],
        'overallStatus': 'error',
        'runtime': '0ms',
        'memory': '0MB'
    }
    sys.stdout = _real_stdout
    print(json.dumps(output))
    sys.exit(0)

all_passed = True

for tc in test_cases:
    args = tc['args']
    expected = tc['expected']
    input_display = tc['inputDisplay']

    try:
        args_copy = copy.deepcopy(args)
        actual = func(*args_copy)

        if compare_mode == 'sorted' and isinstance(actual, list):
            passed = sorted(actual) == sorted(expected)
        elif compare_mode == 'unordered_lists':
            def normalize(lst):
                return sorted([sorted(x) if isinstance(x, list) else x for x in lst])
            passed = normalize(actual) == normalize(expected)
        elif compare_mode == 'float':
            passed = abs(float(actual) - float(expected)) < 0.01
        elif compare_mode == 'palindrome_substring':
            s = args[0]
            passed = (isinstance(actual, str) and actual == actual[::-1]
                      and actual in s and len(actual) == len(expected))
        else:
            passed = actual == expected

        if not passed:
            all_passed = False

        results.append({
            'input': input_display,
            'expectedOutput': json.dumps(expected),
            'actualOutput': json.dumps(actual),
            'passed': passed
        })
    except Exception as e:
        all_passed = False
        results.append({
            'input': input_display,
            'expectedOutput': json.dumps(expected),
            'actualOutput': f"Error: {str(e)}",
            'passed': False
        })

elapsed = time.time() - start_time
elapsed_ms = f"{int(elapsed * 1000)}ms"

output = {
    'compilationSuccess': True,
    'runtimeError': None,
    'testResults': results,
    'overallStatus': 'pass' if all_passed else 'fail',
    'runtime': elapsed_ms,
    'memory': '0MB'
}

# === Restore stdout and print JSON result ===
sys.stdout = _real_stdout
print(json.dumps(output))
