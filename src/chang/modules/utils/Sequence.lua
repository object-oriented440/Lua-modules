---
--- @author zsh in 2022/9/5 0:03
--- ���� (sequence)���������ڱ���һ����������ݣ����е������������ж���Ψһ��λ�ã���������
--- ���������е����ݻᰴ����ӵ�˳��������������

-- �˸�汾�������жϣ����ڴ��������£����ж�����ˣ�
-- 1����ȫ��������ʽ�������ȵ������������ ['n'] ��������ʽ�ر�������
-- 2����ȫ������ { [1]='a',[2]='b' }��ֻ���� {'a','b',...,nil,nil} ��������������� ipairs �������ɣ�

-- ����ģ���ռ����
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- ���벿��
local Assertion = require('chang.modules.utils.Assertion');
local Table = require('chang.modules.utils.Table');

-- ģ���ʼ��
local Sequence = {};
local self = Sequence;

--- {} Ϊ�ձ�
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

    -- keys ����ȫ�����ڿն�
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
    -- �ų� { [1]=1, [2]=2 } �����
    if (not has and ipairs_length == length) then
        return true;
    end
    return false;
end

---ǰ���ǣ���Ҫ���б�
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
    -- NOTE: ������ᵽ������Ե���Ҫ���ˡ�������β�������в��Խ���أ���
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


---�ж�ĳԪ���Ƿ��Ǽ����е�ֵ���� ipairs ���������ϲ��ܳ��ֿ�ֵ��
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

---����
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

---����
function Sequence.intersection(...)
    local args = { ... };
    local length = Table.getSize(args);
    local res = args[1];

    -- NOTE: ��Ŀ����������� 1 and 2 or 3 ��������Ҫ 1 and 2�������߼����㣬�޷���ʾ if else ������
    -- NOTE: ���ǵݹ��ѭ��
    -- �ص��ǣ���һ����ʱ����������ÿ��ѭ��������Ҫ����������浽�ⲿ�������棡
    for i = 2, length do

        --[[ �ò��ֿ��Ա��һ������ ]]
        local tmp = {};
        if (Table.isTable(res) and Table.isTable(args[i])) then
            for _, v in ipairs(args[i]) do
                if (self.contains(res, v)) then
                    table.insert(tmp, v);
                end
            end
        end
        res = tmp;
        tmp = nil; -- ����Ҫ
        --[[ �ò��ֿ��Ա��һ������ ]]

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

-- NOTE: ���� table ��׼���е���Щ������ʹ�� C ����ʵ�ֵģ������ƶ�Ԫ�����漰��ѭ�������ܿ���Ҳ������̫������������ڼ��ٸ�Ԫ�ص�С������˵����ʵ���Ѿ����ӡ�
-- NOTE: ��Щ�������ǲ������еĺ���

---ͷ ��������
function Sequence.push_front(sequence, e)
    table.insert(sequence, 1, e);
    add_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`ͷ ��������
function Sequence.push_front2(sequence, e)
    table.move(sequence, 1, #sequence, 2);
    sequence[1] = e;
    add_list_n(sequence);
    return sequence;
end

---β ��������
function Sequence.push_back(sequence, e)
    table.insert(sequence, e);
    add_list_n(sequence);
    return sequence;
end

---ͷ ɾ������
function Sequence.pop_front(sequence)
    table.remove(sequence, 1);
    sub_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`ͷ ɾ������
function Sequence.pop_front2(sequence)
    table.move(sequence, 2, #sequence, 1);
    sequence[#sequence] = nil; -- ��ʾɾ�����һ��Ԫ��
    sub_list_n(sequence);
    return sequence;
end

---β ɾ������
function Sequence.pop_back(sequence)
    table.remove(sequence);
    sub_list_n(sequence);
    return sequence;
end

---`[Lua 5.3]`���б� a ��Ԫ�ؿ�¡���б� b ��ĩβ
function Sequence.add2(a, b)
    table.move(a, 1, #a, #b + 1, b);
    add_list_n(b, #a);
    return b;
end

-------------------------------------------------------------------------------------------------
-- [[ ���� ]]
-------------------------------------------------------------------------------------------------


return Sequence;