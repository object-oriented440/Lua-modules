---
--- @author zsh in 2022/9/5 0:03
--- 序列 (sequence)：序列用于保存一组有序的数据，所有的数据在序列中都有唯一的位置（索引），
--- 并且序列中的数据会按照添加的顺序来分配索引！

-- 阉割版本的序列判断：（在大多数情况下，序列都是如此）
-- 1、完全不考虑显式表明表长度的情况，比如用 ['n'] 将长度显式地保存起来
-- 2、完全不考虑 { [1]='a',[2]='b' }！只考虑 {'a','b',...,nil,nil} 这种情况。即：用 ipairs 遍历即可！

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
local Assertion = require('chang.modules.utils.Assertion');
local Table = require('chang.modules.utils.Table');

-- 模块初始化
local Sequence = {};
local self = Sequence;

--- {} 为空表
function Sequence.isEmpty(t)
    if (not Table.isTable(t)) then
        return false;
    end

    return not next(t);
end

function Sequence.hasHole(t)
    if (not Table.isTable(t)) then
        return false;
    end

    if (self.isEmpty(t)) then
        return false;
    end

    local keys = {};
    for k, v in pairs(t) do
        if (type(k) == 'number') then
            keys[#keys + 1] = k;
        end
    end
    table.sort(keys);

    -- keys 表完全不存在空洞
    local length = #keys;
    if (keys[length] == length) then
        return false, length;
    end

    return true;
end

function Sequence.isSequence(t)
    if (not Table.isTable(t)) then
        return false;
    end

    if (self.isEmpty(t)) then
        return true;
    end

    local ipairs_length = 0;
    for i, v in ipairs(t) do
        ipairs_length = ipairs_length + 1;
    end

    local has, length = self.hasHole(t);
    -- 排除 { [1]=1, [2]=2 } 的情况
    if (not has and ipairs_length == length) then
        return true;
    end
    return false;
end

---前提是：需要是列表
function Sequence.getLength(t)
    if (not Table.isTable(t)) then
        return false;
    end

    if (self.isSequence(t)) then
        return #t;
    end

    return 0;
end

--[[do
    -- NOTE: 终于体会到软件测试的重要性了。。。如何才能穷尽所有测试结果呢？！
    local t = {};
    t = { 1 };
    t = { nil, 1 };
    t = { 1, nil };
    t = { 1, nil, 2 };
    print('isEmpty     ', self.isEmpty(t));
    print('hasHole     ', (self.hasHole(t)));
    print('isSequence  ', self.isSequence(t));
    print('getLength   ', self.getLength(t));
end]]

--[[do
    -- Test code
    for _, t in pairs({
        { 1, nil, 2, nil },
        { 1, nil, 2, nil, 3, nil },
        { 1, nil, 2, nil, 3, nil, 4, nil }
    }) do
        print(self.isSequence(t));
    end
    return;
end]]


---判断某元素是否是集合中的值，用 ipairs 遍历！集合不能出现空值！
function Sequence.contains(sequence, e)
    if (sequence == nil or e == nil) then
        return false;
    end
    for _, v in ipairs(sequence) do
        if (v == e) then
            return true;
        end
    end
end

---并集
function Sequence.union(...)
    local args = { ... };
    local length = Table.getSize(args);

    local sequence = {};

    for i = 1, length do
        if (Table.isTable(args[i])) then
            for _, v in ipairs(args[i]) do
                sequence[v] = true;
            end
        end
    end

    local res = {};
    for k, v in pairs(sequence) do
        if (v) then
            table.insert(res, k);
        end
    end
    return res;
end

---交集
function Sequence.intersection(...)
    local args = { ... };
    local length = Table.getSize(args);
    local res = args[1];

    -- NOTE: 三目运算符必须是 1 and 2 or 3 ！！！不要 1 and 2，这是逻辑运算，无法表示 if else ！！！
    -- NOTE: 这是递归改循环
    -- 重点是：多一个临时变量！！！每次循环结束都要将这个变量存到外部变量里面！
    for i = 2, length do

        --[[ 该部分可以变成一个函数 ]]
        local tmp = {};
        if (Table.isTable(res) and Table.isTable(args[i])) then
            for _, v in ipairs(args[i]) do
                if (self.contains(res, v)) then
                    table.insert(tmp, v);
                end
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
    Table.print(self.union(
            { 1, 2, 3 },
            { 3, 4, 5 },
            { 4, 5, 6, 10, 23, 4 }
    ))

    --for k in pairs({ 4, 5, 6 }) do
    --    print(k);
    --end

    Table.print(self.intersection(
            { 1, 5, 3 },
            { 3, 4, 5 },
            { 3, 5, 6 }
    ))


    print(#{ nil, 1 });
    return;
end]]

local function add_list_n(sequence, amount)
    amount = amount or 1;
    if (sequence.n) then
        sequence.n = sequence.n + amount;
    end
end

local function sub_list_n(sequence, amount)
    amount = amount or 1;
    if (sequence.n) then
        sequence.n = sequence.n - amount;
    end
end

-- NOTE: 由于 table 标准库中的这些函数是使用 C 语言实现的，所以移动元素所涉及的循环的性能开销也并不是太昂贵，因而，对于几百个元素的小数组来说这种实现已经足矣。
-- NOTE: 这些函数都是操作序列的函数

---头 插入数据
function Sequence.push_front(sequence, e)
    table.insert(sequence, 1, e);
    add_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`头 插入数据
function Sequence.push_front2(sequence, e)
    table.move(sequence, 1, #sequence, 2);
    sequence[1] = e;
    add_list_n(sequence);
    return sequence;
end

---尾 插入数据
function Sequence.push_back(sequence, e)
    table.insert(sequence, e);
    add_list_n(sequence);
    return sequence;
end

---头 删除数据
function Sequence.pop_front(sequence)
    table.remove(sequence, 1);
    sub_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`头 删除数据
function Sequence.pop_front2(sequence)
    table.move(sequence, 2, #sequence, 1);
    sequence[#sequence] = nil; -- 显示删除最后一个元素
    sub_list_n(sequence);
    return sequence;
end

---尾 删除数据
function Sequence.pop_back(sequence)
    table.remove(sequence);
    sub_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`将列表 a 的元素克隆到列表 b 的末尾
function Sequence.add2(a, b)
    table.move(a, 1, #a, #b + 1, b);
    add_list_n(b, #a);
    return b;
end

-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return Sequence;