---
--- @author zsh in 2022/9/5 0:03
--- ���� (sequence)���������ڱ���һ����������ݣ����е������������ж���Ψһ��λ�ã�������
--- ���������е����ݻᰴ����ӵ�˳����������������һ�����ݽṹ����������������ݴ洢�ķ�ʽ

-- ע�⣺
-- 1����ȫ��������ʽ�������ȵ������������ ['n'] ��������ʽ�ر�������
-- 2����ȫ������ { [1]='a',[2]='b' }����Ȼ�ϸ���������˵��Ҳ�����С���ֻ���� {'a','b',...,nil,nil} �������
-- ������ ipairs �������ɣ�

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

local function this(t)
    Assertion.isType(t, 'table');
end


-- ipairs ��������ֵ�ԣ����� nil ��ͣ��ע�⣬ֻҪ�� key = value ���Ǽ�ֵ�ԣ���
-- ipairs: �� 1 ��ʼ��ȡ�б��Ԫ�أ����Ԫ��Ϊ nil ��ֹͣ�����������ǲ���ȫ�ǣ���Ϊ����������ֵ�ԣ�
-- ����˵���� ipairs �������в����㱣�գ�������������£�����˭�������пӸ����� key �أ�
-- �󲿷��б���ͨ�������Ӹ���Ԫ�ش��������� (table.insert��t[#t+1])

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

-- ע��������ԭ�Ӳ�������Ӧ�ú�����������ϣ�
-- �������������ͼ��ı���ǳ���Ϊ 0 ������
function Sequence.isEmpty(t)
    Assertion.isType(t, 'table');

    -- ����Ϊ�յ��ж�
    if (not next(t)) then
        return true;
    end

    -- �ж��Ƿ�����������ͼ�
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

    -- ��ʹ���������͵ļ�ֵ��Ҳ������˵�����в�Ϊ�գ���Ϊ�����е�����ʱ��˳����������ģ�
    -- ���磺{[200]='a'} ��Ҳ�ǿյ�
    --
    -- next(t,k) ����������򷵻ر��е���һ������ k ��Ӧ��ֵ��������Ԫ�ر�������ʱ������ next ���� nil
    -- --> {1,nil} -- Ԫ�ص��������Ϊ��1, length:1�� {1,nil,2,nil} -- Ԫ�ص��������Ϊ��3, length:2��
    -- ipairs ������ֵ�ԣ��� nil ��ͣ��
    --
    -- ע�⣺��������˵��ֻ��Ҫ���沿�ּ��ɣ���Ϊֻ���� {1,2,3,...} �����
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
    -- NOTE: {1,2,3,nil,nil,nil} ���Ԫ�ص����Ϊ 3
    -- NOTE: {1,2,3,nil,nil,nil,7} ���Ԫ�ص����Ϊ 7 --> NOTE: ���� nil ֵ������б�Ľ�����
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
        nil, -- NOTE: ע�⣬����ʹ�� table.insert ����Ԫ��ʱ��nil ���񲻴�����һ��
        nil,
        nil,
        --99999999999
    };
    t['x'] = nil; -- NOTE: �����ڣ�����������
    t[#t + 1] = 666; -- NOTE: �ȼ��� table.insert
end]]

function Sequence.isSequence(t)
    Assertion.isType(t, 'table');

    -- ����ǿ�����
    if (not next(t) or t[1]==nil) then

    end

    local ipairs_length = 0;
    for _, _ in ipairs(t) do
        ipairs_length = ipairs_length + 1;
    end

    -- �ж��Ƿ���ڿն��������� {1,2,nil,3,nil,nil,4} ({1,2,3,nil,nil,nil} ����)
    -- ��ȫ������ { [1]='a',[2]='b' }����Ȼ�ϸ���������˵��Ҳ�����С�
    local has, length = self.hasHole(t);
    if (not has and length == ipairs_length) then
        return true;
    end

    return false;
end

---�������еĻ������� 0
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
-- [[ ���� ]]
-------------------------------------------------------------------------------------------------


return Sequence;