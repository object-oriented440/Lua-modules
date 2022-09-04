---
--- @author zsh in 2022/9/3 19:35
---

local Load = require('chang.modules.utils.Load');
local Table = require('chang.modules.utils.Table');

local a = 100;
local b = {
    100
};
--[[Load.pcall(function(a, b)
    a = a + 1;
    table.insert(b, 200);
    return a;
end, a, b);]]

print(Load.xpcall(function()
    a = 101;
    c = c + 1;
    return 1, 2, 3, 4, 5;
end, function()
    print(debug.getinfo(2, 'Sl').short_src);
end));

print(a);
Table.print(b);
