import json
import sys
import time
import copy
import traceback

__LEETCODE_USER_CODE_INJECT_POINT__

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
            # Compare lists of lists regardless of order (e.g. group anagrams, 3sum)
            def normalize(lst):
                return sorted([sorted(x) if isinstance(x, list) else x for x in lst])
            passed = normalize(actual) == normalize(expected)
        elif compare_mode == 'float':
            passed = abs(float(actual) - float(expected)) < 0.01
        elif compare_mode == 'palindrome_substring':
            # Multiple valid palindrome substrings may exist
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

print(json.dumps(output))
