---
--- @author zsh in 2022/9/5 6:33
---

local Proxy = require('chang.modules.utils.Proxy');
local Table = require('chang.modules.utils.Table');

do
    Proxy.Modules.Load().xpcall(function()
        -- Test code
        -- 改变不了，main chunk 尽量不能执行代码的问题，小问题罢了。
        Table.print(Table.reverse({1,2,3}))
    end)
    return;
end