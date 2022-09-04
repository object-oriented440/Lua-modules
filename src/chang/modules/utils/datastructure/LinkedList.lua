---
--- @author zsh in 2022/8/12 20:19
--- Simple List

do
    -- FIXME
    return;
end

_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

local GF = require('global.GlobalFunction');

local List = {};

-- TODO: #
-- 如果代码中有该标识，说明在标识处有功能代码待编写，待实现的功能在说明中会简略说明。
-- FIXME:
-- 如果代码中有该标识，说明标识处代码需要修正，甚至代码是错误的，不能工作，需要修复，如何修正会在说明中简略说明。

---判断 list 是否为 序列
--[[
    序列：
    对于中间存在空洞（nil 值）的列表而言，序列长度操作符是不可靠的，它只能用于序列（所有元素均不为 nil 的列表）。
    更准确地说：序列（sequence）是由指定的 n 个正数数值类型的键所组成的集合 {1,...,n} 形成的表
    （请注意：值为 nil 的键实际不在表中）。
    特别地，不包含数值类型键的表就是长度为零的序列。
    -- NOTE: # 不同于 fori
    -- n1、对于 fori 来说，遇 nil 则停，跳过键值对
    -- n2、对于 # 来说，# 可以识别 正数类型的键 的 元素（默认添加的键也是的，就是不设置键的元素）

    -- NOTE: ！！！不对啊，经过我的测试，# 和 fori 差不多啊！！！？？？

    NOTE: 先不管那么多，这样记忆：
    综上，如果你的 table 是纯粹当一个连续的数组在用，那么 #t 是很方便的获得table长度的方法；
    但如果你的 table 中 key 的数值不连续，或者有其他类型的 key，
    那么还是不要指望 # 能给出【多有意义】的结果来。
]]
-- TODO: 功能存在缺陷
-- FIXME: 错误代码？
function List:isList(list)
    return type(list) == 'table';
end

function List:empty(list)
    return #list == 0;
end

---将列表 a 中的元素复制到列表 b 的末尾
function List:listAdd(src, dest)
    table.move(src, 1, #src, #dest + 1, dest);
end

function List:insert()
    
end

---头插入
---@param list table[] @列表
---@param newElement userdata @需要插入的新元素
function List:push_front(list, newElement)
    table.move(list, 1, #list, 2);
    list[1] = newElement;
end

---头删除
function List:push_back(list)
    table.move(list, 2, #list, 1);
    list[#list] = nil;
end

---尾删除
function List:pop_back(list)
    if (not self:isList(list)) then
        GF:printErrorInfo('param is not a list');
        return nil;
    end

    if (self:empty(list)) then
        io.write('list is empty\n');
        io.flush();
        return nil;
    end

    local pop = list[#list];
    list[#list] = nil;
    return pop;
end

local function test()
    local list = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    };

    GF:printTableAll(list);

    while (not List:empty(list)) do
        io.write(List:pop_back(list), '\n');
    end

    GF:printTableAll(list);
end

if (true) then
    print(package.path);
    test();
end

return List;
 