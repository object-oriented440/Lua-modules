---
--- @author zsh in 2022/9/3 6:07
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 该 Table 模块被多方依赖，尽量不要依赖非公共模块以外的其他模块

-- 导入部分
local Proxy = require('chang.modules.utils.Proxy');
local Assertion = Proxy.Modules.Assertion();

-- 部分代理
local Sequence = Proxy.Sequence;

-- 模块初始化
local Table = {};
local self = Table;

Table.security = {
    ---如何使用？
    ---
    ---可以这样：a?.b?.c?.d --> (((a or S).b or S).c or S).d 多少个`?`则多少个`(`，即：元素索引
    ---
    ---还可以这样：((a or S).b or S)() 即：函数调用
    S = setmetatable({}, {
        __newindex = function(t, k, v)
            -- DoNothing
        end,
        __call = function(t, ...)
            print('__call >', ...);
            local func_data = debug.getinfo(2, 'Sl');
            print('Table.security.S.__call --> ERROR', func_data.short_src .. ':' .. func_data.currentline .. ': attempted to call a nil value!');
            return nil;
        end
    }),
    ---传入 inst.components.cmp1、func1，可以保证安全调用函数！
    ---
    ---这样调用：inst.components.cmp1:func1()，出错则返回 nil！
    ---@param t table
    ---@param func_name string
    F = function(t, func_name, arg1, ...)
        if (not self.isTable(t) or type(func_name) ~= 'string') then
            return nil;
        end
        if (t and (t == _G and rawget(t, func_name) or t[func_name])) then
            return t[func_name](t, arg1, ...);
        end
    end,
    ---返回 S 和 F
    getSecurities = function()
        return Table.security.S, Table.security.F;
    end
}

---@return boolean
function Table.isTable(v)
    return v and type(v) == 'table';
end


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

-- 说明：next 函数，next(t,k) 返回下一个键以及 k 对应的值，next(t, nil) 返回第二个键和第一个键值
---@return boolean
function Table.isEmpty(t)
    return not next(t);
end

---@return number
function Table.getSize(t)
    if (not self.isTable(t)) then
        return 0;
    end

    local length = 0;
    for _, _ in pairs(t) do
        length = length + 1;
    end
    return length;
end

local function commonprint(content, mode, filepath)
    local File = Proxy.Modules.File();

    if (mode == 't') then
        print(content);
    elseif (mode == 'f') then
        File.writefile(filepath, content, 'w');
    elseif (mode == 'tf') then
        print(content);
        File.writefile(filepath, content, 'w');
    else
        print(content);
    end
end

function Table.print(t, mode, filepath)
    if (not self.isTable(t)) then
        print(t);
        return ;
    end

    local msg = {};
    --table.insert(msg, '{\n');
    for k, v in pairs(t) do
        if (type(k) == 'string') then
            table.insert(msg, '    [\"' .. tostring(k) .. '\"] = ' .. tostring(v) .. ',\n');
        else
            table.insert(msg, '    [' .. tostring(k) .. '] = ' .. tostring(v) .. ',\n');
        end
    end

    if (self.getSize(t) > 0) then
        local last = msg[#msg];
        msg[#msg] = string.sub(last, 1, #last - 2) .. '\n';
    end

    --table.insert(msg, '}\n');

    table.sort(msg, function(a, b)
        local regex = '%["(.+)"%]';
        local k1, k2 = string.match(a, regex), string.match(b, regex);
        if (k1 and k2) then
            return k1 < k2;
        end

        if (not k1 and k2) then
            return false;
        end

        if (k1 and not k2) then
            return true;
        end
    end)

    Proxy.Modules.Sequence().push_front(msg, '{\n');
    Proxy.Modules.Sequence().push_back(msg, '}\n')

    local content = table.concat(msg);

    filepath = filepath or 'chang/modules/tmp/table.txt';
    commonprint(content, mode, filepath);
end

---`[待修正]`
local function enterTable(tab, n, msg)
    -- 获得缩进
    local indentation = '';
    for _ = 1, n do
        indentation = indentation .. '    ';
    end

    -- FIXME: 临时的，避免环的存在导致堆栈溢出！
    if (n == 20) then
        return ;
    end

    -- 递归条件：遍历整张表
    local cnt = 0;
    for k, v in pairs(tab) do
        cnt = cnt + 1;
        if not (type(k) == 'string' and string.match(k, '^_+')) then
            if (type(v) ~= 'table') then
                if (cnt ~= self.getSize(tab)) then
                    table.insert(msg, string.format(type(k) == 'string' and (indentation .. '[\"%s\"] = %s,') or (indentation .. '[%s] = %s,'), tostring(k), tostring(v)));
                else
                    table.insert(msg, string.format(type(k) == 'string' and (indentation .. '[\"%s\"] = %s') or (indentation .. '[%s] = %s'), tostring(k), tostring(v)));
                end
            else
                table.insert(msg, string.format(type(k) == 'string' and (indentation .. '[\"%s\"] = ' .. '{') or (indentation .. '[%s] = ' .. '{'), tostring(k)));
                enterTable(v, n + 1, msg);
                table.insert(msg, cnt ~= self.getSize(tab) and (indentation .. '},') or (indentation .. '}'))
            end
        end
    end

end

-- FIXME: 可能存在共享的子表和环（环：表中存自身）
---`[待修正]`
function Table.deepPrint(t, mode, filepath)
    if (not self.isTable(t)) then
        print(t);
        return ;
    end
    local msg = {};
    table.insert(msg, '{');
    enterTable(t, 1, msg);
    table.insert(msg, '}');

    local content = table.concat(msg, '\n');

    filepath = filepath or 'chang/modules/tmp/deep_table.txt';
    commonprint(content, mode, filepath);
end

function Table.clone(t)
    Assertion.isType(t, 'table');

    local c = {};
    for k, v in pairs(t) do
        c[k] = v;
    end

    return c;
end

---`[Lua 5.3]`浅拷贝表（没必要）
function Table.clone2(t)
    Assertion.isType(t, 'table');

    local c = {};

    -- 不太对！table.move 针对的也是序列吧？
    table.move(t, 1, #t, 1, c);
    return c;
end

function Table.deepClone(t)
    Assertion.isType(t, 'table');

    local c = {};
    for k, v in pairs(t) do
        c[k] = self.deepClone(v); -- 这一堆闭包
    end
    return c;
end

-- Lua 5.2 添加的 table.pack，就是类似 { ... } 这个功能，然后获取 ... 的长度，显式 ['n'] = length 存起来。
-- 在确实需要处理存在空洞的列表时，应该将列表的长度显式地保存起来！
---`[兼容 Lua 5.1]`返回由传入参数构成的列表（顺序不变），用键 ['n'] 将列表的长度显式地保存起来。
---@vararg any
---@return table
function Table.pack(...)
    local args = { ... };
    local length = self.getSize(args);
    args.n = length;
    return args;
end

-- NOTE: table.unpack 用 C 语言编写的，且使用了长度操作符，所以无法有效处理存在空洞的列表。
-- 所以，意思是：千万不要在列表里设置 nil ！！！使用 table.unpack 如果传入的 list 中存在空洞，则会存在问题！
-- 这时候，就要显式地限制返回元素的范围了！
--[[do
    -- Test code
    local t1 = { 1, nil, 2, nil }; -- # -- > 1
    local t2 = { 1, nil, 2, nil, 3, nil }; -- # -- > 3
    local t3 = { 1, nil, 2, nil, 3, nil, 4, nil }; -- # -- > 1

    local ta = table.pack(1, nil, 2, nil); -- # -- > 1
    local tb = table.pack(1, nil, 2, nil, 3, nil); -- # -- > 3
    local tc = table.pack(1, nil, 2, nil, 3, nil, 4, nil); -- # -- > 1

    print(table.unpack(ta, 1, ta.n));
    print(table.unpack(tb, 1, tb.n));
    print(table.unpack(tc, 1, tc.n));
end]]

---`[兼容 Lua 5.1]`建议配合 Table:pack(...) 使用
function Table.unpack(list, i, j)
    i = i or 1;

    -- NOTE：# 千万不要在有空洞的 nil 里面使用！因为有时候居然正确，有时候会错误！
    -- NOTE: 比如：{ 1, nil, 2, nil } --> #list == 1, { 1,nil,2,nil,3,nil } --> #list == 3
    -- NOTE: 不同于 iparis，ipairs 遇 nil 即停！
    j = j or list.n or #list;

    if (i <= j) then
        return list[i], self.unpack(list, i + 1, j);
    end
end


--[[do
    -- Test code: push_front、push_back、pop_front、pop_back
    local a = {};
    Table:push_front(a,1);
    Table:push_front(a,2);

    Table:push_back(a,4);
    Table:push_back(a,3);

    Table:pop_front(a);
    Table:pop_back(a);

    for i, v in ipairs(a) do
        print(i,v);
    end

    Table:print(a);
end]]

---判断某元素是否是表中的键
function Table.containsKey(t, e)
    if (t == nil or e == nil) then
        return false;
    end

    for k, _ in pairs(t) do
        if (k == e) then
            return true;
        end
    end
    return false;
end

---判断某元素是否是表中的值
function Table.containsValue(t, e)
    if (t == nil or e == nil) then
        return false;
    end

    for _, v in pairs(t) do
        if (v == e) then
            return true;
        end
    end
    return false;
end


--[[do
    -- Test code
    local a = {};
    a[1] = a;
    Table:deepPrint(a)
end]]

-------------------------------------------------------------------------------------------------
-- [[ dst util.lua ]]
-------------------------------------------------------------------------------------------------
---返回一个包含 输入表的所有键 的数组表（列表）
---@return table
function Table.getkeys(t)
    if (not self.isTable(t)) then
        return nil;
    end
    local keys = {};
    for k, _ in pairs(t) do
        table.insert(keys, k);
    end
    return keys;
end

---仅适用索引表！不存在任何空洞的那种，1, 2, 3, ..., n
function Table.reverse(t)
    if (not Sequence.isSequence(t)) then
        return t;
    end

    local size = #t;
    local new_sequence = {};

    for i, v in ipairs(t) do
        new_sequence[size - i + 1] = v;
    end

    return new_sequence;
end

--[[do
    Proxy.Modules.Load().xpcall(function()
        -- Test code
        -- 改变不了，main chunk 尽量不能执行代码的问题，小问题罢了。
        Table.print(Table.reverse({1,2,3}))
    end)
    return;
end]]


---table<k,v> --> table<v,k>
function Table.invert(t)
    local invt = {};
    for k, v in pairs(t) do
        invt[v] = k;
    end
    return invt;
end

-- NOTE: 未完待续 ...


--[[do
    -- Test code: Table.security.S、Table.security.F
    local S, F = Table.security.getSecurities();

    --Table.print(S);

    --S();

    print((((inst or S).components or S).cmp1 or S)());

    local i = 100;
    local a = {
        1111,
        func1 = function(t)
            print(t[1]);
            i = 1000;
        end
    };
    print(F(a, 'func1'));
    print(i);
end]]
-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------
---`[弃用]`
function Table:isList(t)
    return Sequence.isSequence(t);
end

---`[弃用]`判断：中间不存在空洞的表！纯列表！
---@return boolean
function Table.isSequence(t)
    return Sequence.isSequence(t);
end


-- NOTE: 由于 table 标准库中的这些函数是使用 C 语言实现的，所以移动元素所涉及的循环的性能开销也并不是太昂贵，因而，对于几百个元素的小数组来说这种实现已经足矣。

---`[弃用]`头 插入数据
function Table.push_front(list, e)
    return Sequence.push_front(list);
end

---`[弃用]``[Lua 5.3]`头 插入数据
function Table.push_front2(list, e)
    return Sequence.push_front2(list);
end

---`[弃用]`尾 插入数据
function Table.push_back(list, e)
    return Sequence.push_back(list);
end

---`[弃用]`头 删除数据
function Table.pop_front(list)
    return Sequence.pop_front(list);
end

---`[弃用]``[Lua 5.3]`头 删除数据
function Table.pop_front2(list)
    return Sequence.pop_front2(list);
end

---`[弃用]`尾 删除数据
function Table.pop_back(list)
    return Sequence.pop_back(list);
end

---`[弃用]``[Lua 5.3]`将列表 a 的元素克隆到列表 b 的末尾
function Table:add2(a, b)
    return Sequence.add2(a, b);
end

return Table;