//给定一个字符串 s ，请你找出其中不含有重复字符的 最长子串 的长度。 
//
// 
//
// 示例 1: 
//
// 
//输入: s = "abcabcbb"
//输出: 3 
//解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
// 
//
// 示例 2: 
//
// 
//输入: s = "bbbbb"
//输出: 1
//解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
// 
//
// 示例 3: 
//
// 
//输入: s = "pwwkew"
//输出: 3
//解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
//     请注意，你的答案必须是 子串 的长度，"pwke" 是一个子序列，不是子串。
// 
//
// 示例 4: 
//
// 
//输入: s = ""
//输出: 0
// 
//
// 
//
// 提示： 
//
// 
// 0 <= s.length <= 5 * 10⁴
// s 由英文字母、数字、符号和空格组成
//
// Related Topics 哈希表 字符串 滑动窗口 👍 6589 👎 0


import java.util.*;

//leetcode submit region begin(Prohibit modification and deletion)
class Solution {
//    public int lengthOfLongestSubstring(String s) {
//        if (s.length() == 0) {
//            return 0;
//        }
//        List<String> list = Arrays.asList(s.split(""));
//        StringBuilder sb = new StringBuilder();
//        int maxLen = 1;
//        String maxStr = "";
//        List<String> listMaxStr = new ArrayList<>();
//        for (String s1 : list) {
//            if (sb.toString().contains(s1)) {
//                maxLen = sb.toString().length() >= maxLen ? sb.toString().length() : maxLen;
//                maxStr = sb.toString().length() >= maxLen ? sb.toString() : maxStr;
//                listMaxStr.add(sb.toString());
//                sb = new StringBuilder(sb.toString().trim().substring(sb.indexOf(s1) + 1, sb.length()));
//            }
//            sb.append(s1);
//        }
//        System.out.println(listMaxStr);
//        return maxLen;
//    }

    public int lengthOfLongestSubstring(String s) {
        int start = 0;
        int end = 0;
        int result = 0;
        Map<String, Integer> map = new HashMap<>();
        for (int i = 0; i < s.length(); i++) {
            String cur = String.valueOf(s.charAt(i));
            if (map.containsKey(cur)) {
                if (map.get(cur) > start) {
                    start = map.get(cur);
                }
            }
            end = i + 1;
            if (result < end - start) {
                result = end - start;
            }
            map.put(String.valueOf(s.charAt(i)), i + 1);
        }
        return result;
    }
}
//leetcode submit region end(Prohibit modification and deletion)
