
local template_config = {
    ["python3"] = {
        ["code_tmpl_start"] = "# @lc code=start",
        ["code_tmpl_end"] = "# @lc code=end",
        ["code"] = [[
''' 
# @lc app=leetcode.cn id=%d lang=%s slug=%s
#
# %d.%s
#
# https://leetcode.%s/problems/%s/description/
#
# %s (%0.2f%%)

%s

# test case:
%s

'''
#
%s
#
%s
#
%s
#
if __name__ == "__main__":
    pass

        ]],
    },
    ["rust"] = {
        ["code_tmpl_start"] = "// @lc code=start",
        ["code_tmpl_end"] = "// @lc code=end",
        ["code"] = [[
/*
* @lc app=leetcode.cn id=%d lang=%s slug=%s
*
* # %d.%s
*
* https://leetcode.%s/problems/%s/description/
*
* %s (%0.2f%%)
*
%s
*
* test case:
%s
*/
struct Solution;
%s
%s
%s

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {

    }
}
        ]],
    },
    ["java"] = {
        ["code_tmpl_start"] = "// @lc code=start",
        ["code_tmpl_end"] = "// @lc code=end",
        ["code"] = [[
/*
* @lc app=leetcode.cn id=%d lang=%s slug=%s
*
* # %d.%s
*
* https://leetcode.%s/problems/%s/description/
*
* %s (%0.2f%%)
*
%s
*
* test case:
%s
*/

%s
%s
%s

public static int main() {
    s = Solution::new()

    return 0;
}
        ]],
    },
    ["cpp"] = {
        ["code_tmpl_start"] = "// @lc code=start",
        ["code_tmpl_end"] = "// @lc code=end",
        ["code"] = [[
/*
* @lc app=leetcode.cn id=%d lang=%s slug=%s
*
* # %d.%s
*
* https://leetcode.%s/problems/%s/description/
*
* %s (%0.2f%%)
*
%s
*
* test case:
%s
*/

using namespace std;

%s
%s
%s

int main() {
    return 0;
}
        ]],
    },
    ["c"] = {
        ["code_tmpl_start"] = "// @lc code=start",
        ["code_tmpl_end"] = "// @lc code=end",
        ["code"] = [[
/*
* @lc app=leetcode.cn id=%d lang=%s slug=%s
*
* # %d.%s
*
* https://leetcode.%s/problems/%s/description/
*
* %s (%0.2f%%)
*
%s
*
* test case:
%s
*/
#include <stdio.h>
%s
%s
%s

int main() {
    return 0;
}
        ]],
    },
    ["go"] = {
        ["code_tmpl_start"] = "// @lc code=start",
        ["code_tmpl_end"] = "// @lc code=end",
        ["code"] = [[
/*
* @lc app=leetcode.cn id=%d lang=%s slug=%s
*
* # %d.%s
*
* https://leetcode.%s/problems/%s/description/
*
* %s (%0.2f%%)
*
%s
*
* test case:
%s
*/

%s
%s
%s

        ]],
    },
}

return template_config
