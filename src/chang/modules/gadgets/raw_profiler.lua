---
--- @author zsh in 2022/8/18 18:22
---

_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

--[[ 原始的性能调优工具，来列出程序执行的每个函数的调用次数 ]]

local Counters = {}; -- 将函数和它们的调用计数关联起来
local Names = {}; -- 关联函数和函数相关的数据表

local function hook()
    local f = debug.getinfo(2, 'f').func;

    if (Counters[f] == nil) then
        -- 如果 'f' 第一次被调用
        Counters[f] = 1;
        Names[f] = debug.getinfo(2, 'Sn');
    else
        Counters[f] = Counters[f] + 1;
    end
end

local function getName(func)
    local info = Names[func];

    if (info.what == 'C') then -- `what`：函数的类型
        return info.name;
        -- `name`：该函数的一个适当的名称，例如保存该函数的全局变量名称
        -- `namewhat`：说明 name 字段的含义，可能值：global local method field '' 空字符串表示 Lua 找不到这个函数的名称
    end

    -- 保存 定义函数的文件名、该函数定义在源代码的第一行的行号
    local lc = string.format('[%s]:%d line', info.short_src, info.linedefined);

    if (info.what ~= 'main' and info.namewhat ~= '') then
        return string.format('%s (%s)', lc, info.name);
    else
        return lc;
    end
end

-- lua.exe raw_profiler xxx文件

local f = assert(loadfile(arg[1]));
debug.sethook(hook, 'c');
f();
debug.sethook();

for func, count in pairs(Counters) do
    print(getName(func), count..' times');
end



