---
--- @author zsh in 2022/9/3 7:22
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
local Assertion = require('chang.modules.utils.Assertion');
local Sequence = require('chang.modules.utils.Sequence');

-- 模块初始化
local Set = {};
local self = Set;


-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------

---`[弃用]`判断某元素是否是集合中的值，用 ipairs 遍历！集合不能出现空值！
function Set.contains(set, e)
    return Sequence.contains(set, e);
end

---`[弃用]`
function Set.union(...)
    return Sequence.union(...);
end

---`[弃用]`
function Set.intersection(...)
    return Sequence.intersection(...);
end

--[[do
    -- Test code
    Table:print(Set:union(
            { 1, 2, 3 },
            { 3, 4, 5 },
            { 4, 5, 6, 10, 23, 4 }
    ))

    --for k in pairs({ 4, 5, 6 }) do
    --    print(k);
    --end

    Table:print(Set:intersection(
            { 1, 5, 3 },
            { 3, 4, 5 },
            { 3, 5, 6 }
    ))


    print(#{ nil, 1 });
end]]


--[[do
    -- Test code
    do
        local function foo()
            bar()
        end

        local function bar()
            foo()
        end
        return ;
    end

    do
        local foo, bar;
        foo = function()
            bar();
        end

        bar = function()
            foo();
        end
        return ;
    end
end]]

return Set;
 