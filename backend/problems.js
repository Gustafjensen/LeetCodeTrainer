const problems = {
    'two-sum': {
        title: 'Two Sum',
        functionName: 'twoSum',
        testCases: [
            { args: [[2, 7, 11, 15], 9], expected: [0, 1], inputDisplay: 'nums = [2,7,11,15], target = 9' },
            { args: [[3, 2, 4], 6], expected: [1, 2], inputDisplay: 'nums = [3,2,4], target = 6' },
            { args: [[3, 3], 6], expected: [0, 1], inputDisplay: 'nums = [3,3], target = 6' }
        ],
        compareFunction: 'sorted'
    },
    'reverse-string': {
        title: 'Reverse String',
        functionName: 'reverseString',
        testCases: [
            { args: [["h", "e", "l", "l", "o"]], expected: ["o", "l", "l", "e", "h"],
              inputDisplay: 's = ["h","e","l","l","o"]' },
            { args: [["H", "a", "n", "n", "a", "h"]], expected: ["h", "a", "n", "n", "a", "H"],
              inputDisplay: 's = ["H","a","n","n","a","h"]' }
        ],
        compareFunction: 'exact'
    },
    'fizz-buzz': {
        title: 'FizzBuzz',
        functionName: 'fizzBuzz',
        testCases: [
            { args: [3], expected: ["1", "2", "Fizz"], inputDisplay: 'n = 3' },
            { args: [5], expected: ["1", "2", "Fizz", "4", "Buzz"], inputDisplay: 'n = 5' },
            { args: [15], expected: ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"],
              inputDisplay: 'n = 15' }
        ],
        compareFunction: 'exact'
    },
    'valid-palindrome': {
        title: 'Valid Palindrome',
        functionName: 'isPalindrome',
        testCases: [
            { args: ["A man, a plan, a canal: Panama"], expected: true,
              inputDisplay: 's = "A man, a plan, a canal: Panama"' },
            { args: ["race a car"], expected: false, inputDisplay: 's = "race a car"' },
            { args: [" "], expected: true, inputDisplay: 's = " "' }
        ],
        compareFunction: 'exact'
    },
    'max-subarray': {
        title: 'Maximum Subarray',
        functionName: 'maxSubArray',
        testCases: [
            { args: [[-2, 1, -3, 4, -1, 2, 1, -5, 4]], expected: 6,
              inputDisplay: 'nums = [-2,1,-3,4,-1,2,1,-5,4]' },
            { args: [[1]], expected: 1, inputDisplay: 'nums = [1]' },
            { args: [[5, 4, -1, 7, 8]], expected: 23, inputDisplay: 'nums = [5,4,-1,7,8]' },
            { args: [[-1]], expected: -1, inputDisplay: 'nums = [-1]' }
        ],
        compareFunction: 'exact'
    },
    'valid-parentheses': {
        title: 'Valid Parentheses',
        functionName: 'isValid',
        testCases: [
            { args: ["()"], expected: true, inputDisplay: 's = "()"' },
            { args: ["()[]{}"], expected: true, inputDisplay: 's = "()[]{}"' },
            { args: ["(]"], expected: false, inputDisplay: 's = "(]"' },
            { args: ["([)]"], expected: false, inputDisplay: 's = "([)]"' },
            { args: ["{[]}"], expected: true, inputDisplay: 's = "{[]}"' }
        ],
        compareFunction: 'exact'
    },
    'merge-sorted-lists': {
        title: 'Merge Two Sorted Lists',
        functionName: 'mergeTwoLists',
        testCases: [
            { args: [[1, 2, 4], [1, 3, 4]], expected: [1, 1, 2, 3, 4, 4],
              inputDisplay: 'list1 = [1,2,4], list2 = [1,3,4]' },
            { args: [[], []], expected: [], inputDisplay: 'list1 = [], list2 = []' },
            { args: [[], [0]], expected: [0], inputDisplay: 'list1 = [], list2 = [0]' }
        ],
        compareFunction: 'exact'
    },
    'climbing-stairs': {
        title: 'Climbing Stairs',
        functionName: 'climbStairs',
        testCases: [
            { args: [2], expected: 2, inputDisplay: 'n = 2' },
            { args: [3], expected: 3, inputDisplay: 'n = 3' },
            { args: [5], expected: 8, inputDisplay: 'n = 5' },
            { args: [1], expected: 1, inputDisplay: 'n = 1' }
        ],
        compareFunction: 'exact'
    }
};

module.exports = problems;
