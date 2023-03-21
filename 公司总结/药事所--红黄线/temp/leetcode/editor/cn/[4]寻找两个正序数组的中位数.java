//给定两个大小分别为 m 和 n 的正序（从小到大）数组 nums1 和 nums2。请你找出并返回这两个正序数组的 中位数 。 
//
// 算法的时间复杂度应该为 O(log (m+n)) 。 
//
// 
//
// 示例 1： 
//
// 
//输入：nums1 = [1,3], nums2 = [2]
//输出：2.00000
//解释：合并数组 = [1,2,3] ，中位数 2
// 
//
// 示例 2： 
//
// 
//输入：nums1 = [1,2], nums2 = [3,4]
//输出：2.50000
//解释：合并数组 = [1,2,3,4] ，中位数 (2 + 3) / 2 = 2.5
// 
//
// 示例 3： 
//
// 
//输入：nums1 = [0,0], nums2 = [0,0]
//输出：0.00000
// 
//
// 示例 4： 
//
// 
//输入：nums1 = [], nums2 = [1]
//输出：1.00000
// 
//
// 示例 5： 
//
// 
//输入：nums1 = [2], nums2 = []
//输出：2.00000
// 
//
// 
//
// 提示： 
//
// 
// nums1.length == m 
// nums2.length == n 
// 0 <= m <= 1000 
// 0 <= n <= 1000 
// 1 <= m + n <= 2000 
// -10⁶ <= nums1[i], nums2[i] <= 10⁶ 
// 
// Related Topics 数组 二分查找 分治 👍 4791 👎 0


import java.util.Arrays;

//leetcode submit region begin(Prohibit modification and deletion)
class Solution {
//    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
//        int res[] = new int[nums1.length + nums2.length];
//        int r = 0;
//        int n1 = 0;
//        int n2 = 0;
//        while (n1 < nums1.length && n2 < nums2.length) {
//            if (nums1[n1] <= nums2[n2]) {
//                res[r] = nums1[n1];
//                n1++;
//            } else {
//                res[r] = nums2[n2];
//                n2++;
//            }
//            r++;
//        }
//        //如果nums2已经遍历完了
//        if (n1 != nums1.length) {
//            for (int i = n1; i < nums1.length; i++) {
//                res[r] = nums1[i];
//                r++;
//            }
//        } else {
//            for (int i = n2; i < nums2.length; i++) {
//                res[r] = nums2[i];
//                r++;
//            }
//        }
//        Arrays.stream(res).forEach(it2->{
//            System.out.println(it2);
//        });
//        int result = 0;
//        if (res.length % 2 == 0) {
//            result = (res[res.length / 2] + res[res.length / 2 - 1]) / 2;
//        } else {
//            result = res[(int) Math.floor(res.length / 2)];
//        }
//        return result;
//    }

    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int[] res = new int[nums1.length + nums2.length];
        int r = 0;
        int n1 = 0;
        int n2 = 0;
        while (n1 < nums1.length && n2 < nums2.length) {
            res[r++] = nums1[n1] < nums2[n2] ? nums1[n1++] : nums2[n2++];
        }
        while (n1 < nums1.length) {
            res[r++] = nums1[n1++];
        }
        while (n2 < nums2.length) {
            res[r++] = nums2[n2++];
        }
        Arrays.stream(res).forEach(it -> {
            System.out.println(it);
        });
        return res.length % 2 == 1 ? res[res.length / 2] : ((double) (res[res.length / 2] + res[res.length / 2 - 1])) / 2;
    }

    //分治
//    public static void mergeSort(int[] arr, int L, int R) {
//        if (L == R) {
//            return;
//        } else {
//            int M = (L + R) / 2;
//            mergeSort(arr, L, M);
//            mergeSort(arr, M + 1, R);
//            merge(arr, L, M + 1, R);
//        }
//    }

    //归并
//    public static void merge(int[] arr, int L, int M, int R) {
//        int leftSize = M - L;
//        int rightSize = R - M + 1;
//        int[] leftArr = new int[leftSize];
//        int[] rightArr = new int[rightSize];
//        for (int i = L; i < M; i++) {
//            leftArr[i - L] = arr[i];
//        }
//        for (int j = M; j <= R; j++) {
//            rightArr[j - M] = arr[j];
//        }
//        int i = 0;
//        int j = 0;
//        int k = L;
//        while (i < leftSize && j < rightSize) {
//            if (leftArr[i] < rightArr[j]) {
//                arr[k++] = leftArr[i++];
//            } else {
//                arr[k++] = rightArr[j++];
//            }
//        }
//        while (i < leftSize) {
//            arr[k++] = leftArr[i++];
//        }
//        while (j < rightSize) {
//            arr[k++] = rightArr[j++];
//        }
//    }

}
//leetcode submit region end(Prohibit modification and deletion)
