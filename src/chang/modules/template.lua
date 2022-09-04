---
--- @author zsh in 2022/9/3 23:47
---

-- 导入部分
local Assertion = require('chang.modules.utils.Assertion');
local Date = require('chang.modules.utils.Date');
local Debug = require('chang.modules.utils.Debug');
local File = require('chang.modules.utils.File');
local Load = require('chang.modules.utils.Load');
local Math = require('chang.modules.utils.Math');
local Set = require('chang.modules.utils.incomplete.Set');
local Table = require('chang.modules.utils.Table');


-- 主程序块部分

:: T1 ::
do
    -- Test code
    goto T2;
    _G[1] = 'number1';
    _G[true] = 'true';
    _G[{}] = '{}';
    _G[function()
    end] = 'function';
    Table.print(_G, 't');
    Table.deepPrint(_G, 'f');
end

:: T2 ::
print('T2-');










