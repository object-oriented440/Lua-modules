---
--- @author zsh in 2022/9/3 23:41
--- 字符串缓冲区

-- 不要用在 for 循环中用 .. 连接字符串，用 table 缓存所有字符串，然后 table.concat 一次性连接
-- 注意了，使用 table.concat 后不要在 .. 连接 table.concat 的结果了，因为那时候这个结果可能已经很长了。

local Load = require('chang.modules.utils.Load');

-- 举例：
local filename = 'chang/modules/utils/datastructure/StringBuffer.txt';

Load.xpcall(function()
    local f = assert(io.open(filename,'w'));
    f:write([=[
        1\n .. filename
        2
        3
        4
        5
    ]=]);
    f:close();

    local old_input = io.input();
    io.input(filename);
    local t = {};
    for line in io.lines() do
        t[#t + 1] = line;
    end
    io.input(old_input);
    local content = table.concat(t, '\n');
    print(content);
end)