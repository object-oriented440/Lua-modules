---
--- @author zsh in 2022/9/5 6:33
---

local Proxy = require('chang.modules.utils.Proxy');
local Table = require('chang.modules.utils.Table');

do
    Proxy.Modules.Load().xpcall(function()
        -- Test code
        -- �ı䲻�ˣ�main chunk ��������ִ�д�������⣬С������ˡ�
        Table.print(Table.reverse({1,2,3}))
    end)
    return;
end