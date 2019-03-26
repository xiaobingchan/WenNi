class Solution:
    def twoSum(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
        d = {}
        for i, n in enumerate(nums):
            m = target - n
            if m in d:
                return [d[m], i]
            else:

                d[n] = i

num = [2, 7, 4, 9]
target = 13
sol = Solution()
a=sol.twoSum(num, target)
print(a)