---
--- @author zsh in 2022/8/27 0:42
---

--[[do
    local a = function()
    end;
    local b = a;
    --b = nil;
    print(a, b);

    -- 测试发现函数是有地址的！但是仍是传值。

    return;
end]]

--[[local fns = {};
local counters = {};
debug.sethook(function()
    local f = debug.getinfo(2, 'f').func;
    local name = debug.getinfo(2, 'n').name;

    if (not fns[f]) then
        fns[f] = name;
        counters[f] = 1;
    else
        counters[f] = 2;
        -- 看这里：这样的话，哪怕函数被复制了！也会报错！因为第一次执行的名字已经存起来了。
        if (fns[f] == 'modifyPackagePath') then
            error('please require this module, do not dofile this module!', 3);
            -- stackLevel == 2 时，测试发现，hook 的函数（mask = 'c'）会在函数调用的开头调用！
        end
    end
end, 'c');]]

-- 无效！！！
if (true) then
    return nil;
end

local function modifyPackagePath(level, stackLevel)
    level = level or 2;
    stackLevel = stackLevel or 2;

    --print(package.path);

    --local Table = require('m3.chang.modules.utils.Table');

    -- 此时，package.path 的结构为：`;xxx;xxx;xxx`

    -- 存储从 package.path 中截取的部分，<';xxx/xxx/',number>
    local prefixs = {};

    for p in string.gmatch(package.path, ';[^;]*') do
        --print(p);

        local i = string.find(p, '?.lua');
        if (i) then
            prefixs[string.sub(p, 1, i - 1)] = i;
        end
    end

    -- 文件的 source 路径
    local source = debug.getinfo(stackLevel, 'S').source;

    -- 存储被截取的 source，便于查找，<'%w'> 单词
    local source_cuts = {};
    for cut in string.gmatch(source, '[^@][^/\\]+') do
        --print(cut);

        table.insert(source_cuts, string.find(cut, '[/\\]') and string.sub(cut, 2) or cut);
    end

    --Table:print(source_cuts);

    -- 当前文件相对更目录所在的层次（ require 会搜索 IDE 设置的 Sources Root 路径）
    local find = source_cuts[#source_cuts - level];
    --print(find);

    -- 添加 package.path
    for v, i in pairs(prefixs) do
        package.path = (v .. find .. string.sub(v, -1, -1) .. '?.lua') .. package.path;
    end

    --for p in string.gmatch(package.path, ';[^;]*') do
    --    print(p);
    --end
end

modifyPackagePath(3);

--debug.sethook();

return true;

