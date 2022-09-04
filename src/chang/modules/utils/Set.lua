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

-- 模块初始化
local Set = {};
local self = Set;

local function returnList(set)
    local res = {};
    for k, v in pairs(set) do
        if (v) then
            table.insert(res, k);
        end
    end
    return res;
end

---判断某元素是否是集合中的值，用 ipairs 遍历！集合不能出现空值！
function Set.contains(set, e)
    Assertion.isType(set, 'list'); -- 判断：中间不存在空洞的表！纯列表！

    if (set == nil or e == nil) then
        return false;
    end

    if (set.n) then
        for i = 1, set.n do
            if (set[i] == e) then
                return true;
            end
        end
    else
        for _, v in ipairs(set) do
            if (v == e) then
                return true;
            end
        end
    end
end

function Set.new(list)
    Assertion.isType(list, 'list'); -- 判断：中间不存在空洞的表！纯列表！

    list = list or {};
    local set = {};

    for _, v in ipairs(list) do
        set[v] = true;
    end

    return set;
end

---参数即参数内容都是列表！
local function paramsIsSequence(...)
    local args = { ... };
    Assertion.isType(args, 'sequence');

    local length = #args;
    for i = 1, length do
        Assertion.isType(args[i], 'sequence');
    end

    return true;
end

---并集
---@vararg table[]
function Set.union(...)
    paramsIsSequence(...);

    local args = { ... };
    local length = #args;

    local set = self.new();

    for i = 1, length do
        for _, v in ipairs(args[i]) do
            if (true or not set[v]--[[不需要判断]]) then
                set[v] = true;
            end
        end
    end

    return returnList(set);
end

---交集
---@vararg table[]
function Set.intersection(...)
    paramsIsSequence(...);

    local args = { ... };
    local length = #args;
    local res = args[1];

    -- NOTE: 三目运算符必须是 1 and 2 or 3 ！！！不要 1 and 2，这是逻辑运算，无法表示 if else ！！！
    -- NOTE: 这是递归改循环
    -- 重点是：多一个临时变量！！！每次循环结束都要将这个变量存到外部变量里面！
    for i = 2, length do

        --[[ 该部分可以变成一个函数 ]]
        local tmp = {};
        for _, v in ipairs(args[i]) do
            if (self.contains(res, v)) then
                table.insert(tmp, v);
            end
        end
        res = tmp;
        tmp = nil; -- 不需要
        --[[ 该部分可以变成一个函数 ]]

    end

    return res;
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

-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------



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
 