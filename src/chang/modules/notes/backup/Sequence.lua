---
--- @author zsh in 2022/9/5 0:03
--- 序列 (sequence)：序列用于保存一组有序的数据，所有的数据在序列中都有唯一的位置（索引）
--- 并且序列中的数据会按照添加的顺序来分配索引！是一种数据结构：计算机中用于数据存储的方式

-- 注意：
-- 1、完全不考虑显式表明表长度的情况，比如用 ['n'] 将长度显式地保存起来
-- 2、完全不考虑 { [1]='a',[2]='b' }，虽然严格意义上来说这也是序列。即只考虑 {'a','b',...,nil,nil} 这种情况
-- 即：用 ipairs 遍历即可！

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

local function this(t)
    Assertion.isType(t, 'table');
end


-- ipairs 会跳过键值对，遇到 nil 即停（注意，只要是 key = value 就是键值对），
-- ipairs: 从 1 开始获取列表的元素，如果元素为 nil 则停止！！！（但是不完全是，因为：会跳过键值对）
-- 所以说，用 ipairs 索引序列并不算保险，但是正常情况下，序列谁会脑子有坑给它加 key 呢？
-- 大部分列表都是通过逐个添加各个元素创建出来的 (table.insert、t[#t+1])

--[[do
    -- Test code
    for i, v in ipairs({
        [1] = '1-a',
        'a','b'
    }) do
        print(i,v); --> NOTE: 1 a    2 b
    end
    return;
end]]

-- 注意这算是原子操作，不应该和其他函数耦合！
-- 不包含数字类型键的表就是长度为 0 的序列
function Sequence.isEmpty(t)
    Assertion.isType(t, 'table');

    -- 绝对为空的判断
    if (not next(t)) then
        return true;
    end

    -- 判断是否存在数字类型键
    do
        local has_number = false;
        for k, _ in pairs(t) do
            if (type(k) == 'number') then
                has_number = true;
                break ;
            end
        end
        if (not has_number) then
            return true;
        end
    end

    -- 即使有数字类型的键值，也并不能说明序列不为空，因为序列中的数据时按顺序分配索引的！
    -- 比如：{[200]='a'} 这也是空的
    --
    -- next(t,k) 会以随机次序返回表中的下一个键及 k 对应的值，当所有元素被遍历完时，函数 next 返回 nil
    -- --> {1,nil} -- 元素的最大索引为：1, length:1， {1,nil,2,nil} -- 元素的最大索引为：3, length:2！
    -- ipairs 跳过键值对！遇 nil 即停！
    --
    -- 注意：按道理来说，只需要下面部分即可，因为只考虑 {1,2,3,...} 的情况
    local empty = true;
    for _, _ in ipairs(t) do
        empty = false;
        break ;
    end
    return empty;
end

function Sequence.hasHole(t)
    Assertion.isType(t, 'table');

    if (self.isEmpty(t)) then
        return false;
    end

    local keys = {};
    for k, _ in pairs(t) do
        if (type(k) == 'number') then
            table.insert(keys, k);
        end
    end
    table.sort(keys);
    local length = #keys;
    if (keys[length] == length) then
        return false, length;
    end
    return true;
end


--[[do
    -- NOTE: {1,2,3,nil,nil,nil} 最大元素的序号为 3
    -- NOTE: {1,2,3,nil,nil,nil,7} 最大元素的序号为 7 --> NOTE: 利用 nil 值来标记列表的结束！
    local function absolute_getLength(t)
        local length = 0;
        for k, v in pairs(t) do
            length = length + 1;
            print(k, v);
        end

        return length;
    end

    -- Test code
    local t = {
        [100] = 100,
        11, 22, 33, 444,
        nil, -- NOTE: 注意，当我使用 table.insert 插入元素时，nil 就像不存在了一样
        nil,
        nil,
        --99999999999
    };
    t['x'] = nil; -- NOTE: 不存在，遍历不到！
    t[#t + 1] = 666; -- NOTE: 等价于 table.insert
end]]

function Sequence.isSequence(t)
    Assertion.isType(t, 'table');

    -- 如果是空序列
    if (not next(t) or t[1]==nil) then

    end

    local ipairs_length = 0;
    for _, _ in ipairs(t) do
        ipairs_length = ipairs_length + 1;
    end

    -- 判断是否存在空洞，即形如 {1,2,nil,3,nil,nil,4} ({1,2,3,nil,nil,nil} 不算)
    -- 完全不考虑 { [1]='a',[2]='b' }，虽然严格意义上来说这也是序列。
    local has, length = self.hasHole(t);
    if (not has and length == ipairs_length) then
        return true;
    end

    return false;
end

---不是序列的话，返回 0
function Sequence.getLength(t)
    Assertion.isType(t, 'table');

    local length = 0;
    if (self.isSequence(t)) then
        for _, _ in ipairs(t) do
            length = length + 1;
        end
    end

    return length;
end

do
    local t = {};
    t = { 1 };
    t = { nil, 1 };
    print(#{ nil, 1 });
    print(t[1])
    --t = { 1, nil };
    --t = { 1, nil, 2 };
    print('isEmpty     ', self.isEmpty(t));
    print('hasHole     ', (self.hasHole(t)));
    print('isSequence  ', self.isSequence(t));
    print('getLength   ', self.getLength(t));
end

-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return Sequence;