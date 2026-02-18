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
    }
};

module.exports = problems;
