---
--- @author zsh in 2022/9/3 23:47
---

-- ���벿��
local Assertion = require('chang.modules.utils.Assertion');
local Date = require('chang.modules.utils.Date');
local Debug = require('chang.modules.utils.Debug');
local File = require('chang.modules.utils.File');
local IO = require('chang.modules.utils.IO');
local Load = require('chang.modules.utils.Load');
local Math = require('chang.modules.utils.Math');
local Set = require('chang.modules.utils.Set');
local String = require('chang.modules.utils.String');
local Table = require('chang.modules.utils.Table');
local Thread = require('chang.modules.utils.Thread');
local Timer = require('chang.modules.utils.Timer');

-- ������鲿��

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










