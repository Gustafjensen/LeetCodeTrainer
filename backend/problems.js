const problems = {
    'tutorial-add-two': {
        title: 'Add Two Numbers',
        functionName: 'addTwo',
        testCases: [
            { args: [1, 2], expected: 3, inputDisplay: 'a = 1, b = 2' },
            { args: [0, 0], expected: 0, inputDisplay: 'a = 0, b = 0' },
            { args: [-5, 10], expected: 5, inputDisplay: 'a = -5, b = 10' }
        ],
        compareFunction: 'exact'
    },
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
    },
    'contains-duplicate': {
        title: 'Contains Duplicate',
        functionName: 'containsDuplicate',
        testCases: [
            { args: [[1, 2, 3, 1]], expected: true, inputDisplay: 'nums = [1,2,3,1]' },
            { args: [[1, 2, 3, 4]], expected: false, inputDisplay: 'nums = [1,2,3,4]' },
            { args: [[1, 1, 1, 3, 3, 4, 3, 2, 4, 2]], expected: true, inputDisplay: 'nums = [1,1,1,3,3,4,3,2,4,2]' }
        ],
        compareFunction: 'exact'
    },
    'valid-anagram': {
        title: 'Valid Anagram',
        functionName: 'isAnagram',
        testCases: [
            { args: ["anagram", "nagaram"], expected: true, inputDisplay: 's = "anagram", t = "nagaram"' },
            { args: ["rat", "car"], expected: false, inputDisplay: 's = "rat", t = "car"' },
            { args: ["listen", "silent"], expected: true, inputDisplay: 's = "listen", t = "silent"' }
        ],
        compareFunction: 'exact'
    },
    'palindrome-number': {
        title: 'Palindrome Number',
        functionName: 'isPalindromeNumber',
        testCases: [
            { args: [121], expected: true, inputDisplay: 'x = 121' },
            { args: [-121], expected: false, inputDisplay: 'x = -121' },
            { args: [10], expected: false, inputDisplay: 'x = 10' },
            { args: [0], expected: true, inputDisplay: 'x = 0' }
        ],
        compareFunction: 'exact'
    },
    'roman-to-integer': {
        title: 'Roman to Integer',
        functionName: 'romanToInt',
        testCases: [
            { args: ["III"], expected: 3, inputDisplay: 's = "III"' },
            { args: ["LVIII"], expected: 58, inputDisplay: 's = "LVIII"' },
            { args: ["MCMXCIV"], expected: 1994, inputDisplay: 's = "MCMXCIV"' },
            { args: ["IX"], expected: 9, inputDisplay: 's = "IX"' }
        ],
        compareFunction: 'exact'
    },
    'longest-common-prefix': {
        title: 'Longest Common Prefix',
        functionName: 'longestCommonPrefix',
        testCases: [
            { args: [["flower", "flow", "flight"]], expected: "fl", inputDisplay: 'strs = ["flower","flow","flight"]' },
            { args: [["dog", "racecar", "car"]], expected: "", inputDisplay: 'strs = ["dog","racecar","car"]' },
            { args: [["a"]], expected: "a", inputDisplay: 'strs = ["a"]' }
        ],
        compareFunction: 'exact'
    },
    'length-of-last-word': {
        title: 'Length of Last Word',
        functionName: 'lengthOfLastWord',
        testCases: [
            { args: ["Hello World"], expected: 5, inputDisplay: 's = "Hello World"' },
            { args: ["   fly me   to   the moon  "], expected: 4, inputDisplay: 's = "   fly me   to   the moon  "' },
            { args: ["luffy is still joyboy"], expected: 6, inputDisplay: 's = "luffy is still joyboy"' }
        ],
        compareFunction: 'exact'
    },
    'search-insert-position': {
        title: 'Search Insert Position',
        functionName: 'searchInsert',
        testCases: [
            { args: [[1, 3, 5, 6], 5], expected: 2, inputDisplay: 'nums = [1,3,5,6], target = 5' },
            { args: [[1, 3, 5, 6], 2], expected: 1, inputDisplay: 'nums = [1,3,5,6], target = 2' },
            { args: [[1, 3, 5, 6], 7], expected: 4, inputDisplay: 'nums = [1,3,5,6], target = 7' },
            { args: [[1, 3, 5, 6], 0], expected: 0, inputDisplay: 'nums = [1,3,5,6], target = 0' }
        ],
        compareFunction: 'exact'
    },
    'single-number': {
        title: 'Single Number',
        functionName: 'singleNumber',
        testCases: [
            { args: [[2, 2, 1]], expected: 1, inputDisplay: 'nums = [2,2,1]' },
            { args: [[4, 1, 2, 1, 2]], expected: 4, inputDisplay: 'nums = [4,1,2,1,2]' },
            { args: [[1]], expected: 1, inputDisplay: 'nums = [1]' }
        ],
        compareFunction: 'exact'
    },
    'missing-number': {
        title: 'Missing Number',
        functionName: 'missingNumber',
        testCases: [
            { args: [[3, 0, 1]], expected: 2, inputDisplay: 'nums = [3,0,1]' },
            { args: [[0, 1]], expected: 2, inputDisplay: 'nums = [0,1]' },
            { args: [[9, 6, 4, 2, 3, 5, 7, 0, 1]], expected: 8, inputDisplay: 'nums = [9,6,4,2,3,5,7,0,1]' }
        ],
        compareFunction: 'exact'
    },
    'ransom-note': {
        title: 'Ransom Note',
        functionName: 'canConstruct',
        testCases: [
            { args: ["a", "b"], expected: false, inputDisplay: 'ransomNote = "a", magazine = "b"' },
            { args: ["aa", "ab"], expected: false, inputDisplay: 'ransomNote = "aa", magazine = "ab"' },
            { args: ["aa", "aab"], expected: true, inputDisplay: 'ransomNote = "aa", magazine = "aab"' }
        ],
        compareFunction: 'exact'
    },
    'isomorphic-strings': {
        title: 'Isomorphic Strings',
        functionName: 'isIsomorphic',
        testCases: [
            { args: ["egg", "add"], expected: true, inputDisplay: 's = "egg", t = "add"' },
            { args: ["foo", "bar"], expected: false, inputDisplay: 's = "foo", t = "bar"' },
            { args: ["paper", "title"], expected: true, inputDisplay: 's = "paper", t = "title"' },
            { args: ["badc", "baba"], expected: false, inputDisplay: 's = "badc", t = "baba"' }
        ],
        compareFunction: 'exact'
    },
    'best-time-to-buy-sell-stock': {
        title: 'Best Time to Buy and Sell Stock',
        functionName: 'maxProfit',
        testCases: [
            { args: [[7, 1, 5, 3, 6, 4]], expected: 5, inputDisplay: 'prices = [7,1,5,3,6,4]' },
            { args: [[7, 6, 4, 3, 1]], expected: 0, inputDisplay: 'prices = [7,6,4,3,1]' },
            { args: [[2, 4, 1]], expected: 2, inputDisplay: 'prices = [2,4,1]' }
        ],
        compareFunction: 'exact'
    },
    'move-zeroes': {
        title: 'Move Zeroes',
        functionName: 'moveZeroes',
        testCases: [
            { args: [[0, 1, 0, 3, 12]], expected: [1, 3, 12, 0, 0], inputDisplay: 'nums = [0,1,0,3,12]' },
            { args: [[0]], expected: [0], inputDisplay: 'nums = [0]' },
            { args: [[1, 0, 0, 2, 3]], expected: [1, 2, 3, 0, 0], inputDisplay: 'nums = [1,0,0,2,3]' }
        ],
        compareFunction: 'exact'
    },
    'plus-one': {
        title: 'Plus One',
        functionName: 'plusOne',
        testCases: [
            { args: [[1, 2, 3]], expected: [1, 2, 4], inputDisplay: 'digits = [1,2,3]' },
            { args: [[4, 3, 2, 1]], expected: [4, 3, 2, 2], inputDisplay: 'digits = [4,3,2,1]' },
            { args: [[9]], expected: [1, 0], inputDisplay: 'digits = [9]' },
            { args: [[9, 9, 9]], expected: [1, 0, 0, 0], inputDisplay: 'digits = [9,9,9]' }
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
    'group-anagrams': {
        title: 'Group Anagrams',
        functionName: 'groupAnagrams',
        testCases: [
            { args: [["eat", "tea", "tan", "ate", "nat", "bat"]],
              expected: [["bat"], ["nat", "tan"], ["ate", "eat", "tea"]],
              inputDisplay: 'strs = ["eat","tea","tan","ate","nat","bat"]' },
            { args: [[""]],
              expected: [[""]],
              inputDisplay: 'strs = [""]' },
            { args: [["a"]],
              expected: [["a"]],
              inputDisplay: 'strs = ["a"]' }
        ],
        compareFunction: 'unordered_lists'
    },
    'product-except-self': {
        title: 'Product of Array Except Self',
        functionName: 'productExceptSelf',
        testCases: [
            { args: [[1, 2, 3, 4]], expected: [24, 12, 8, 6], inputDisplay: 'nums = [1,2,3,4]' },
            { args: [[-1, 1, 0, -3, 3]], expected: [0, 0, 9, 0, 0], inputDisplay: 'nums = [-1,1,0,-3,3]' }
        ],
        compareFunction: 'exact'
    },
    'container-with-most-water': {
        title: 'Container With Most Water',
        functionName: 'maxArea',
        testCases: [
            { args: [[1, 8, 6, 2, 5, 4, 8, 3, 7]], expected: 49, inputDisplay: 'height = [1,8,6,2,5,4,8,3,7]' },
            { args: [[1, 1]], expected: 1, inputDisplay: 'height = [1,1]' },
            { args: [[4, 3, 2, 1, 4]], expected: 16, inputDisplay: 'height = [4,3,2,1,4]' }
        ],
        compareFunction: 'exact'
    },
    'three-sum': {
        title: '3Sum',
        functionName: 'threeSum',
        testCases: [
            { args: [[-1, 0, 1, 2, -1, -4]], expected: [[-1, -1, 2], [-1, 0, 1]],
              inputDisplay: 'nums = [-1,0,1,2,-1,-4]' },
            { args: [[0, 1, 1]], expected: [], inputDisplay: 'nums = [0,1,1]' },
            { args: [[0, 0, 0]], expected: [[0, 0, 0]], inputDisplay: 'nums = [0,0,0]' }
        ],
        compareFunction: 'unordered_lists'
    },
    'house-robber': {
        title: 'House Robber',
        functionName: 'rob',
        testCases: [
            { args: [[1, 2, 3, 1]], expected: 4, inputDisplay: 'nums = [1,2,3,1]' },
            { args: [[2, 7, 9, 3, 1]], expected: 12, inputDisplay: 'nums = [2,7,9,3,1]' },
            { args: [[2, 1, 1, 2]], expected: 4, inputDisplay: 'nums = [2,1,1,2]' }
        ],
        compareFunction: 'exact'
    },
    'coin-change': {
        title: 'Coin Change',
        functionName: 'coinChange',
        testCases: [
            { args: [[1, 5, 10], 12], expected: 3, inputDisplay: 'coins = [1,5,10], amount = 12' },
            { args: [[2], 3], expected: -1, inputDisplay: 'coins = [2], amount = 3' },
            { args: [[1], 0], expected: 0, inputDisplay: 'coins = [1], amount = 0' },
            { args: [[1, 2, 5], 11], expected: 3, inputDisplay: 'coins = [1,2,5], amount = 11' }
        ],
        compareFunction: 'exact'
    },
    'unique-paths': {
        title: 'Unique Paths',
        functionName: 'uniquePaths',
        testCases: [
            { args: [3, 7], expected: 28, inputDisplay: 'm = 3, n = 7' },
            { args: [3, 2], expected: 3, inputDisplay: 'm = 3, n = 2' },
            { args: [1, 1], expected: 1, inputDisplay: 'm = 1, n = 1' }
        ],
        compareFunction: 'exact'
    },
    'jump-game': {
        title: 'Jump Game',
        functionName: 'canJump',
        testCases: [
            { args: [[2, 3, 1, 1, 4]], expected: true, inputDisplay: 'nums = [2,3,1,1,4]' },
            { args: [[3, 2, 1, 0, 4]], expected: false, inputDisplay: 'nums = [3,2,1,0,4]' },
            { args: [[0]], expected: true, inputDisplay: 'nums = [0]' }
        ],
        compareFunction: 'exact'
    },
    'sort-colors': {
        title: 'Sort Colors',
        functionName: 'sortColors',
        testCases: [
            { args: [[2, 0, 2, 1, 1, 0]], expected: [0, 0, 1, 1, 2, 2], inputDisplay: 'nums = [2,0,2,1,1,0]' },
            { args: [[2, 0, 1]], expected: [0, 1, 2], inputDisplay: 'nums = [2,0,1]' },
            { args: [[0]], expected: [0], inputDisplay: 'nums = [0]' }
        ],
        compareFunction: 'exact'
    },
    'min-stack': {
        title: 'Min Stack',
        functionName: 'minStack',
        testCases: [
            { args: [["push", "push", "push", "getMin", "pop", "top", "getMin"],
                     [[-2], [0], [-3], [], [], [], []]],
              expected: [null, null, null, -3, null, 0, -2],
              inputDisplay: 'ops = ["push","push","push","getMin","pop","top","getMin"], args = [[-2],[0],[-3],[],[],[],[]]' },
            { args: [["push", "push", "getMin", "push", "getMin", "pop", "getMin"],
                     [[5], [3], [], [1], [], [], []]],
              expected: [null, null, 3, null, 1, null, 3],
              inputDisplay: 'ops = ["push","push","getMin","push","getMin","pop","getMin"], args = [[5],[3],[],[1],[],[],[]]' }
        ],
        compareFunction: 'exact'
    },
    'search-rotated-array': {
        title: 'Search in Rotated Sorted Array',
        functionName: 'search',
        testCases: [
            { args: [[4, 5, 6, 7, 0, 1, 2], 0], expected: 4, inputDisplay: 'nums = [4,5,6,7,0,1,2], target = 0' },
            { args: [[4, 5, 6, 7, 0, 1, 2], 3], expected: -1, inputDisplay: 'nums = [4,5,6,7,0,1,2], target = 3' },
            { args: [[1], 0], expected: -1, inputDisplay: 'nums = [1], target = 0' },
            { args: [[1], 1], expected: 0, inputDisplay: 'nums = [1], target = 1' }
        ],
        compareFunction: 'exact'
    },
    'merge-intervals': {
        title: 'Merge Intervals',
        functionName: 'merge',
        testCases: [
            { args: [[[1, 3], [2, 6], [8, 10], [15, 18]]], expected: [[1, 6], [8, 10], [15, 18]],
              inputDisplay: 'intervals = [[1,3],[2,6],[8,10],[15,18]]' },
            { args: [[[1, 4], [4, 5]]], expected: [[1, 5]],
              inputDisplay: 'intervals = [[1,4],[4,5]]' },
            { args: [[[1, 4], [0, 4]]], expected: [[0, 4]],
              inputDisplay: 'intervals = [[1,4],[0,4]]' }
        ],
        compareFunction: 'exact'
    },
    'remove-duplicates-sorted': {
        title: 'Remove Duplicates from Sorted Array',
        functionName: 'removeDuplicates',
        testCases: [
            { args: [[1, 1, 2]], expected: 2, inputDisplay: 'nums = [1,1,2]' },
            { args: [[0, 0, 1, 1, 1, 2, 2, 3, 3, 4]], expected: 5, inputDisplay: 'nums = [0,0,1,1,1,2,2,3,3,4]' },
            { args: [[1]], expected: 1, inputDisplay: 'nums = [1]' }
        ],
        compareFunction: 'exact'
    },
    'longest-substring-no-repeat': {
        title: 'Longest Substring Without Repeating Characters',
        functionName: 'lengthOfLongestSubstring',
        testCases: [
            { args: ["abcabcbb"], expected: 3, inputDisplay: 's = "abcabcbb"' },
            { args: ["bbbbb"], expected: 1, inputDisplay: 's = "bbbbb"' },
            { args: ["pwwkew"], expected: 3, inputDisplay: 's = "pwwkew"' },
            { args: [""], expected: 0, inputDisplay: 's = ""' }
        ],
        compareFunction: 'exact'
    },
    'best-time-buy-sell-stock-ii': {
        title: 'Best Time to Buy and Sell Stock II',
        functionName: 'maxProfitII',
        testCases: [
            { args: [[7, 1, 5, 3, 6, 4]], expected: 7, inputDisplay: 'prices = [7,1,5,3,6,4]' },
            { args: [[1, 2, 3, 4, 5]], expected: 4, inputDisplay: 'prices = [1,2,3,4,5]' },
            { args: [[7, 6, 4, 3, 1]], expected: 0, inputDisplay: 'prices = [7,6,4,3,1]' }
        ],
        compareFunction: 'exact'
    },
    'rotate-array': {
        title: 'Rotate Array',
        functionName: 'rotate',
        testCases: [
            { args: [[1, 2, 3, 4, 5, 6, 7], 3], expected: [5, 6, 7, 1, 2, 3, 4],
              inputDisplay: 'nums = [1,2,3,4,5,6,7], k = 3' },
            { args: [[-1, -100, 3, 99], 2], expected: [3, 99, -1, -100],
              inputDisplay: 'nums = [-1,-100,3,99], k = 2' }
        ],
        compareFunction: 'exact'
    },
    'pow-x-n': {
        title: 'Pow(x, n)',
        functionName: 'myPow',
        testCases: [
            { args: [2.0, 10], expected: 1024.0, inputDisplay: 'x = 2.0, n = 10' },
            { args: [2.1, 3], expected: 9.261, inputDisplay: 'x = 2.1, n = 3' },
            { args: [2.0, -2], expected: 0.25, inputDisplay: 'x = 2.0, n = -2' }
        ],
        compareFunction: 'float'
    },
    'spiral-matrix': {
        title: 'Spiral Matrix',
        functionName: 'spiralOrder',
        testCases: [
            { args: [[[1, 2, 3], [4, 5, 6], [7, 8, 9]]], expected: [1, 2, 3, 6, 9, 8, 7, 4, 5],
              inputDisplay: 'matrix = [[1,2,3],[4,5,6],[7,8,9]]' },
            { args: [[[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]], expected: [1, 2, 3, 4, 8, 12, 11, 10, 9, 5, 6, 7],
              inputDisplay: 'matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]' }
        ],
        compareFunction: 'exact'
    },
    'word-search': {
        title: 'Word Search',
        functionName: 'exist',
        testCases: [
            { args: [[["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCCED"],
              expected: true,
              inputDisplay: 'board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"' },
            { args: [[["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "SEE"],
              expected: true,
              inputDisplay: 'board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "SEE"' },
            { args: [[["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCB"],
              expected: false,
              inputDisplay: 'board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCB"' }
        ],
        compareFunction: 'exact'
    },
    'trapping-rain-water': {
        title: 'Trapping Rain Water',
        functionName: 'trap',
        testCases: [
            { args: [[0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]], expected: 6,
              inputDisplay: 'height = [0,1,0,2,1,0,1,3,2,1,2,1]' },
            { args: [[4, 2, 0, 3, 2, 5]], expected: 9,
              inputDisplay: 'height = [4,2,0,3,2,5]' }
        ],
        compareFunction: 'exact'
    },
    'longest-palindromic-substring': {
        title: 'Longest Palindromic Substring',
        functionName: 'longestPalindrome',
        testCases: [
            { args: ["babad"], expected: "bab", inputDisplay: 's = "babad"' },
            { args: ["cbbd"], expected: "bb", inputDisplay: 's = "cbbd"' },
            { args: ["a"], expected: "a", inputDisplay: 's = "a"' }
        ],
        compareFunction: 'palindrome_substring'
    },
    'majority-element': {
        title: 'Majority Element',
        functionName: 'majorityElement',
        testCases: [
            { args: [[3, 2, 3]], expected: 3, inputDisplay: 'nums = [3,2,3]' },
            { args: [[2, 2, 1, 1, 1, 2, 2]], expected: 2, inputDisplay: 'nums = [2,2,1,1,1,2,2]' },
            { args: [[1]], expected: 1, inputDisplay: 'nums = [1]' }
        ],
        compareFunction: 'exact'
    },
    'happy-number': {
        title: 'Happy Number',
        functionName: 'isHappy',
        testCases: [
            { args: [19], expected: true, inputDisplay: 'n = 19' },
            { args: [2], expected: false, inputDisplay: 'n = 2' },
            { args: [1], expected: true, inputDisplay: 'n = 1' },
            { args: [7], expected: true, inputDisplay: 'n = 7' }
        ],
        compareFunction: 'exact'
    },
    'power-of-three': {
        title: 'Power of Three',
        functionName: 'isPowerOfThree',
        testCases: [
            { args: [27], expected: true, inputDisplay: 'n = 27' },
            { args: [0], expected: false, inputDisplay: 'n = 0' },
            { args: [-1], expected: false, inputDisplay: 'n = -1' },
            { args: [9], expected: true, inputDisplay: 'n = 9' },
            { args: [45], expected: false, inputDisplay: 'n = 45' }
        ],
        compareFunction: 'exact'
    },
    'merge-sorted-array': {
        title: 'Merge Sorted Array',
        functionName: 'mergeSortedArray',
        testCases: [
            { args: [[1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3], expected: [1, 2, 2, 3, 5, 6],
              inputDisplay: 'nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3' },
            { args: [[1], 1, [], 0], expected: [1],
              inputDisplay: 'nums1 = [1], m = 1, nums2 = [], n = 0' },
            { args: [[0], 0, [1], 1], expected: [1],
              inputDisplay: 'nums1 = [0], m = 0, nums2 = [1], n = 1' }
        ],
        compareFunction: 'exact'
    },
    'remove-element': {
        title: 'Remove Element',
        functionName: 'removeElement',
        testCases: [
            { args: [[3, 2, 2, 3], 3], expected: 2, inputDisplay: 'nums = [3,2,2,3], val = 3' },
            { args: [[0, 1, 2, 2, 3, 0, 4, 2], 2], expected: 5, inputDisplay: 'nums = [0,1,2,2,3,0,4,2], val = 2' }
        ],
        compareFunction: 'exact'
    },
    'excel-column-number': {
        title: 'Excel Sheet Column Number',
        functionName: 'titleToNumber',
        testCases: [
            { args: ["A"], expected: 1, inputDisplay: 'columnTitle = "A"' },
            { args: ["AB"], expected: 28, inputDisplay: 'columnTitle = "AB"' },
            { args: ["ZY"], expected: 701, inputDisplay: 'columnTitle = "ZY"' },
            { args: ["Z"], expected: 26, inputDisplay: 'columnTitle = "Z"' }
        ],
        compareFunction: 'exact'
    },
    'intersection-two-arrays': {
        title: 'Intersection of Two Arrays II',
        functionName: 'intersect',
        testCases: [
            { args: [[1, 2, 2, 1], [2, 2]], expected: [2, 2], inputDisplay: 'nums1 = [1,2,2,1], nums2 = [2,2]' },
            { args: [[4, 9, 5], [9, 4, 9, 8, 4]], expected: [4, 9], inputDisplay: 'nums1 = [4,9,5], nums2 = [9,4,9,8,4]' }
        ],
        compareFunction: 'sorted'
    },
    'add-binary': {
        title: 'Add Binary',
        functionName: 'addBinary',
        testCases: [
            { args: ["11", "1"], expected: "100", inputDisplay: 'a = "11", b = "1"' },
            { args: ["1010", "1011"], expected: "10101", inputDisplay: 'a = "1010", b = "1011"' },
            { args: ["0", "0"], expected: "0", inputDisplay: 'a = "0", b = "0"' }
        ],
        compareFunction: 'exact'
    },
    'sqrt-x': {
        title: 'Sqrt(x)',
        functionName: 'mySqrt',
        testCases: [
            { args: [4], expected: 2, inputDisplay: 'x = 4' },
            { args: [8], expected: 2, inputDisplay: 'x = 8' },
            { args: [0], expected: 0, inputDisplay: 'x = 0' },
            { args: [1], expected: 1, inputDisplay: 'x = 1' }
        ],
        compareFunction: 'exact'
    },
    'top-k-frequent': {
        title: 'Top K Frequent Elements',
        functionName: 'topKFrequent',
        testCases: [
            { args: [[1, 1, 1, 2, 2, 3], 2], expected: [1, 2], inputDisplay: 'nums = [1,1,1,2,2,3], k = 2' },
            { args: [[1], 1], expected: [1], inputDisplay: 'nums = [1], k = 1' }
        ],
        compareFunction: 'sorted'
    },
    'subsets': {
        title: 'Subsets',
        functionName: 'subsets',
        testCases: [
            { args: [[1, 2, 3]], expected: [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]],
              inputDisplay: 'nums = [1,2,3]' },
            { args: [[0]], expected: [[], [0]], inputDisplay: 'nums = [0]' }
        ],
        compareFunction: 'unordered_lists'
    },
    'permutations': {
        title: 'Permutations',
        functionName: 'permute',
        testCases: [
            { args: [[1, 2, 3]], expected: [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]],
              inputDisplay: 'nums = [1,2,3]' },
            { args: [[0, 1]], expected: [[0, 1], [1, 0]], inputDisplay: 'nums = [0,1]' },
            { args: [[1]], expected: [[1]], inputDisplay: 'nums = [1]' }
        ],
        compareFunction: 'unordered_lists'
    },
    'letter-combinations': {
        title: 'Letter Combinations of a Phone Number',
        functionName: 'letterCombinations',
        testCases: [
            { args: ["23"], expected: ["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"],
              inputDisplay: 'digits = "23"' },
            { args: [""], expected: [], inputDisplay: 'digits = ""' },
            { args: ["2"], expected: ["a", "b", "c"], inputDisplay: 'digits = "2"' }
        ],
        compareFunction: 'sorted'
    },
    'generate-parentheses': {
        title: 'Generate Parentheses',
        functionName: 'generateParenthesis',
        testCases: [
            { args: [3], expected: ["((()))", "(()())", "(())()", "()(())", "()()()"],
              inputDisplay: 'n = 3' },
            { args: [1], expected: ["()"], inputDisplay: 'n = 1' }
        ],
        compareFunction: 'sorted'
    },
    'set-matrix-zeroes': {
        title: 'Set Matrix Zeroes',
        functionName: 'setZeroes',
        testCases: [
            { args: [[[1, 1, 1], [1, 0, 1], [1, 1, 1]]], expected: [[1, 0, 1], [0, 0, 0], [1, 0, 1]],
              inputDisplay: 'matrix = [[1,1,1],[1,0,1],[1,1,1]]' },
            { args: [[[0, 1, 2, 0], [3, 4, 5, 2], [1, 3, 1, 5]]], expected: [[0, 0, 0, 0], [0, 4, 5, 0], [0, 3, 1, 0]],
              inputDisplay: 'matrix = [[0,1,2,0],[3,4,5,2],[1,3,1,5]]' }
        ],
        compareFunction: 'exact'
    },
    'max-product-subarray': {
        title: 'Maximum Product Subarray',
        functionName: 'maxProduct',
        testCases: [
            { args: [[2, 3, -2, 4]], expected: 6, inputDisplay: 'nums = [2,3,-2,4]' },
            { args: [[-2, 0, -1]], expected: 0, inputDisplay: 'nums = [-2,0,-1]' },
            { args: [[-2, 3, -4]], expected: 24, inputDisplay: 'nums = [-2,3,-4]' }
        ],
        compareFunction: 'exact'
    },
    'find-min-rotated': {
        title: 'Find Minimum in Rotated Sorted Array',
        functionName: 'findMin',
        testCases: [
            { args: [[3, 4, 5, 1, 2]], expected: 1, inputDisplay: 'nums = [3,4,5,1,2]' },
            { args: [[4, 5, 6, 7, 0, 1, 2]], expected: 0, inputDisplay: 'nums = [4,5,6,7,0,1,2]' },
            { args: [[11, 13, 15, 17]], expected: 11, inputDisplay: 'nums = [11,13,15,17]' }
        ],
        compareFunction: 'exact'
    },
    'longest-increasing-subsequence': {
        title: 'Longest Increasing Subsequence',
        functionName: 'lengthOfLIS',
        testCases: [
            { args: [[10, 9, 2, 5, 3, 7, 101, 18]], expected: 4, inputDisplay: 'nums = [10,9,2,5,3,7,101,18]' },
            { args: [[0, 1, 0, 3, 2, 3]], expected: 4, inputDisplay: 'nums = [0,1,0,3,2,3]' },
            { args: [[7, 7, 7, 7, 7, 7, 7]], expected: 1, inputDisplay: 'nums = [7,7,7,7,7,7,7]' }
        ],
        compareFunction: 'exact'
    },
    'word-break': {
        title: 'Word Break',
        functionName: 'wordBreak',
        testCases: [
            { args: ["leetcode", ["leet", "code"]], expected: true, inputDisplay: 's = "leetcode", wordDict = ["leet","code"]' },
            { args: ["applepenapple", ["apple", "pen"]], expected: true, inputDisplay: 's = "applepenapple", wordDict = ["apple","pen"]' },
            { args: ["catsandog", ["cats", "dog", "sand", "and", "cat"]], expected: false,
              inputDisplay: 's = "catsandog", wordDict = ["cats","dog","sand","and","cat"]' }
        ],
        compareFunction: 'exact'
    },
    'decode-ways': {
        title: 'Decode Ways',
        functionName: 'numDecodings',
        testCases: [
            { args: ["12"], expected: 2, inputDisplay: 's = "12"' },
            { args: ["226"], expected: 3, inputDisplay: 's = "226"' },
            { args: ["06"], expected: 0, inputDisplay: 's = "06"' },
            { args: ["10"], expected: 1, inputDisplay: 's = "10"' }
        ],
        compareFunction: 'exact'
    },
    'kth-largest-element': {
        title: 'Kth Largest Element in an Array',
        functionName: 'findKthLargest',
        testCases: [
            { args: [[3, 2, 1, 5, 6, 4], 2], expected: 5, inputDisplay: 'nums = [3,2,1,5,6,4], k = 2' },
            { args: [[3, 2, 3, 1, 2, 4, 5, 5, 6], 4], expected: 4, inputDisplay: 'nums = [3,2,3,1,2,4,5,5,6], k = 4' }
        ],
        compareFunction: 'exact'
    },
    'first-missing-positive': {
        title: 'First Missing Positive',
        functionName: 'firstMissingPositive',
        testCases: [
            { args: [[1, 2, 0]], expected: 3, inputDisplay: 'nums = [1,2,0]' },
            { args: [[3, 4, -1, 1]], expected: 2, inputDisplay: 'nums = [3,4,-1,1]' },
            { args: [[7, 8, 9, 11, 12]], expected: 1, inputDisplay: 'nums = [7,8,9,11,12]' }
        ],
        compareFunction: 'exact'
    },
    'minimum-window-substring': {
        title: 'Minimum Window Substring',
        functionName: 'minWindow',
        testCases: [
            { args: ["ADOBECODEBANC", "ABC"], expected: "BANC", inputDisplay: 's = "ADOBECODEBANC", t = "ABC"' },
            { args: ["a", "a"], expected: "a", inputDisplay: 's = "a", t = "a"' },
            { args: ["a", "aa"], expected: "", inputDisplay: 's = "a", t = "aa"' }
        ],
        compareFunction: 'exact'
    },
    'edit-distance': {
        title: 'Edit Distance',
        functionName: 'minDistance',
        testCases: [
            { args: ["horse", "ros"], expected: 3, inputDisplay: 'word1 = "horse", word2 = "ros"' },
            { args: ["intention", "execution"], expected: 5, inputDisplay: 'word1 = "intention", word2 = "execution"' },
            { args: ["", "a"], expected: 1, inputDisplay: 'word1 = "", word2 = "a"' }
        ],
        compareFunction: 'exact'
    },
    'largest-rectangle-histogram': {
        title: 'Largest Rectangle in Histogram',
        functionName: 'largestRectangleArea',
        testCases: [
            { args: [[2, 1, 5, 6, 2, 3]], expected: 10, inputDisplay: 'heights = [2,1,5,6,2,3]' },
            { args: [[2, 4]], expected: 4, inputDisplay: 'heights = [2,4]' },
            { args: [[1]], expected: 1, inputDisplay: 'heights = [1]' }
        ],
        compareFunction: 'exact'
    },
    'reverse-linked-list': {
        title: 'Reverse Linked List',
        functionName: 'reverseList',
        testCases: [
            { args: [[1, 2, 3, 4, 5]], expected: [5, 4, 3, 2, 1], inputDisplay: 'head = [1,2,3,4,5]' },
            { args: [[1, 2]], expected: [2, 1], inputDisplay: 'head = [1,2]' },
            { args: [[]], expected: [], inputDisplay: 'head = []' }
        ],
        compareFunction: 'exact'
    },
    'max-depth-binary-tree': {
        title: 'Maximum Depth of Binary Tree',
        functionName: 'maxDepth',
        testCases: [
            { args: [[3, 9, 20, null, null, 15, 7]], expected: 3, inputDisplay: 'root = [3,9,20,null,null,15,7]' },
            { args: [[1, null, 2]], expected: 2, inputDisplay: 'root = [1,null,2]' },
            { args: [[]], expected: 0, inputDisplay: 'root = []' }
        ],
        compareFunction: 'exact'
    },
    'invert-binary-tree': {
        title: 'Invert Binary Tree',
        functionName: 'invertTree',
        testCases: [
            { args: [[4, 2, 7, 1, 3, 6, 9]], expected: [4, 7, 2, 9, 6, 3, 1], inputDisplay: 'root = [4,2,7,1,3,6,9]' },
            { args: [[2, 1, 3]], expected: [2, 3, 1], inputDisplay: 'root = [2,1,3]' },
            { args: [[]], expected: [], inputDisplay: 'root = []' }
        ],
        compareFunction: 'exact'
    },
    'symmetric-tree': {
        title: 'Symmetric Tree',
        functionName: 'isSymmetric',
        testCases: [
            { args: [[1, 2, 2, 3, 4, 4, 3]], expected: true, inputDisplay: 'root = [1,2,2,3,4,4,3]' },
            { args: [[1, 2, 2, null, 3, null, 3]], expected: false, inputDisplay: 'root = [1,2,2,null,3,null,3]' }
        ],
        compareFunction: 'exact'
    },
    'number-of-1-bits': {
        title: 'Number of 1 Bits',
        functionName: 'hammingWeight',
        testCases: [
            { args: [11], expected: 3, inputDisplay: 'n = 11' },
            { args: [128], expected: 1, inputDisplay: 'n = 128' },
            { args: [255], expected: 8, inputDisplay: 'n = 255' }
        ],
        compareFunction: 'exact'
    },
    'implement-queue-stacks': {
        title: 'Implement Queue using Stacks',
        functionName: 'queueUsingStacks',
        testCases: [
            { args: [["push", "push", "peek", "pop", "empty"], [[1], [2], [], [], []]], expected: [null, null, 1, 1, false],
              inputDisplay: 'ops = ["push","push","peek","pop","empty"], args = [[1],[2],[],[],[]]' },
            { args: [["push", "push", "push", "pop", "pop"], [[1], [2], [3], [], []]], expected: [null, null, null, 1, 2],
              inputDisplay: 'ops = ["push","push","push","pop","pop"], args = [[1],[2],[3],[],[]]' }
        ],
        compareFunction: 'exact'
    },
    'find-duplicate-number': {
        title: 'Find the Duplicate Number',
        functionName: 'findDuplicate',
        testCases: [
            { args: [[1, 3, 4, 2, 2]], expected: 2, inputDisplay: 'nums = [1,3,4,2,2]' },
            { args: [[3, 1, 3, 4, 2]], expected: 3, inputDisplay: 'nums = [3,1,3,4,2]' },
            { args: [[1, 1]], expected: 1, inputDisplay: 'nums = [1,1]' }
        ],
        compareFunction: 'exact'
    },
    'binary-tree-level-order': {
        title: 'Binary Tree Level Order Traversal',
        functionName: 'levelOrder',
        testCases: [
            { args: [[3, 9, 20, null, null, 15, 7]], expected: [[3], [9, 20], [15, 7]], inputDisplay: 'root = [3,9,20,null,null,15,7]' },
            { args: [[1]], expected: [[1]], inputDisplay: 'root = [1]' },
            { args: [[]], expected: [], inputDisplay: 'root = []' }
        ],
        compareFunction: 'exact'
    },
    'validate-bst': {
        title: 'Validate Binary Search Tree',
        functionName: 'isValidBST',
        testCases: [
            { args: [[2, 1, 3]], expected: true, inputDisplay: 'root = [2,1,3]' },
            { args: [[5, 1, 4, null, null, 3, 6]], expected: false, inputDisplay: 'root = [5,1,4,null,null,3,6]' }
        ],
        compareFunction: 'exact'
    },
    'course-schedule': {
        title: 'Course Schedule',
        functionName: 'canFinish',
        testCases: [
            { args: [2, [[1, 0]]], expected: true, inputDisplay: 'numCourses = 2, prerequisites = [[1,0]]' },
            { args: [2, [[1, 0], [0, 1]]], expected: false, inputDisplay: 'numCourses = 2, prerequisites = [[1,0],[0,1]]' },
            { args: [3, [[0, 1], [0, 2], [1, 2]]], expected: true, inputDisplay: 'numCourses = 3, prerequisites = [[0,1],[0,2],[1,2]]' }
        ],
        compareFunction: 'exact'
    },
    'number-of-islands': {
        title: 'Number of Islands',
        functionName: 'numIslands',
        testCases: [
            { args: [[["1", "1", "1", "1", "0"], ["1", "1", "0", "1", "0"], ["1", "1", "0", "0", "0"], ["0", "0", "0", "0", "0"]]], expected: 1,
              inputDisplay: 'grid = [["1","1","1","1","0"],["1","1","0","1","0"],["1","1","0","0","0"],["0","0","0","0","0"]]' },
            { args: [[["1", "1", "0", "0", "0"], ["1", "1", "0", "0", "0"], ["0", "0", "1", "0", "0"], ["0", "0", "0", "1", "1"]]], expected: 3,
              inputDisplay: 'grid = [["1","1","0","0","0"],["1","1","0","0","0"],["0","0","1","0","0"],["0","0","0","1","1"]]' }
        ],
        compareFunction: 'exact'
    },
    'kth-smallest-bst': {
        title: 'Kth Smallest Element in a BST',
        functionName: 'kthSmallest',
        testCases: [
            { args: [[3, 1, 4, null, 2], 1], expected: 1, inputDisplay: 'root = [3,1,4,null,2], k = 1' },
            { args: [[5, 3, 6, 2, 4, null, null, 1], 3], expected: 3, inputDisplay: 'root = [5,3,6,2,4,null,null,1], k = 3' }
        ],
        compareFunction: 'exact'
    },
    'lru-cache': {
        title: 'LRU Cache',
        functionName: 'lruCache',
        testCases: [
            { args: [2, ["put", "put", "get", "put", "get", "put", "get", "get", "get"], [[1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]],
              expected: [null, null, 1, null, -1, null, -1, 3, 4],
              inputDisplay: 'capacity = 2, ops = ["put","put","get","put","get","put","get","get","get"], args = [[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]]' }
        ],
        compareFunction: 'exact'
    },
    'task-scheduler': {
        title: 'Task Scheduler',
        functionName: 'leastInterval',
        testCases: [
            { args: [["A", "A", "A", "B", "B", "B"], 2], expected: 8, inputDisplay: 'tasks = ["A","A","A","B","B","B"], n = 2' },
            { args: [["A", "A", "A", "B", "B", "B"], 0], expected: 6, inputDisplay: 'tasks = ["A","A","A","B","B","B"], n = 0' },
            { args: [["A", "A", "A", "A", "A", "A", "B", "C", "D", "E", "F", "G"], 2], expected: 16,
              inputDisplay: 'tasks = ["A","A","A","A","A","A","B","C","D","E","F","G"], n = 2' }
        ],
        compareFunction: 'exact'
    },
    'word-ladder': {
        title: 'Word Ladder',
        functionName: 'ladderLength',
        testCases: [
            { args: ["hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"]], expected: 5,
              inputDisplay: 'beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]' },
            { args: ["hit", "cog", ["hot", "dot", "dog", "lot", "log"]], expected: 0,
              inputDisplay: 'beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log"]' }
        ],
        compareFunction: 'exact'
    },
    'merge-k-sorted-lists': {
        title: 'Merge k Sorted Lists',
        functionName: 'mergeKLists',
        testCases: [
            { args: [[[1, 4, 5], [1, 3, 4], [2, 6]]], expected: [1, 1, 2, 3, 4, 4, 5, 6],
              inputDisplay: 'lists = [[1,4,5],[1,3,4],[2,6]]' },
            { args: [[]], expected: [], inputDisplay: 'lists = []' },
            { args: [[[],[]]], expected: [], inputDisplay: 'lists = [[],[]]' }
        ],
        compareFunction: 'exact'
    },
    'serialize-deserialize-tree': {
        title: 'Serialize and Deserialize Binary Tree',
        functionName: 'codec',
        testCases: [
            { args: [[1, 2, 3, null, null, 4, 5]], expected: [1, 2, 3, null, null, 4, 5], inputDisplay: 'root = [1,2,3,null,null,4,5]' },
            { args: [[]], expected: [], inputDisplay: 'root = []' },
            { args: [[1]], expected: [1], inputDisplay: 'root = [1]' }
        ],
        compareFunction: 'exact'
    },
    'alien-dictionary': {
        title: 'Alien Dictionary',
        functionName: 'alienOrder',
        testCases: [
            { args: [["wrt", "wrf", "er", "ett", "rftt"]], expected: "wertf", inputDisplay: 'words = ["wrt","wrf","er","ett","rftt"]' },
            { args: [["z", "x"]], expected: "zx", inputDisplay: 'words = ["z","x"]' },
            { args: [["z", "x", "z"]], expected: "", inputDisplay: 'words = ["z","x","z"]' }
        ],
        compareFunction: 'exact'
    }
};

module.exports = problems;
