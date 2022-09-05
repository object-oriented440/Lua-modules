---
--- @author zsh in 2022/9/5 6:11
---

-- ����ģ���ռ����
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- ���벿��
-- ����ģ�飬����������������е�������ģ�飬�Ҵ˴��Ĵ��뾡������ Lua ��������Ҫ�� main chunk ��ִ�д��룡
-- ��ҪΪ�˽��ѭ���������⣬�Լ������޸� require �� modulename

-- ģ���ʼ��
local Proxy = {};
local self = Proxy;

-- ��������ҵ���߼�������ģ�飩
Proxy.Modules = {
    Assertion = function()
        return require('chang.modules.utils.Assertion');
    end,
    Date = function()
        return require('chang.modules.utils.Date');
    end,
    Debug = function()
        return require('chang.modules.utils.Debug');
    end,
    File = function()
        return require('chang.modules.utils.File');
    end,
    Load = function()
        return require('chang.modules.utils.Load');
    end,
    Math = function()
        return require('chang.modules.utils.Math');
    end,
    Sequence = function()
        return require('chang.modules.utils.Sequence');
    end,
    Table = function()
        return require('chang.modules.utils.Table');
    end,
}

-- ���ִ�������ģ���ڲ�ʹ�ã������������ͷ�� require ���µ�ѭ���������⣬��Ϊģ���ڲ�һ�㲢�������ʹ�ã�
-- NOTE: ʹ�ò��ִ���������Ӧ�ò�����������ˡ����ǣ�A.f1 --> B.f1 --> A.f2 --> A.f1���������������
-- NOTE: ģ��� main chunk ���뾡����Ҫִ�д��룡���� A: main chunk --> require B --> require A --> A: main chunk ... ѭ������ջ�����
Proxy.Sequence = {
    isSequence = function(...)
        return Proxy.Modules.Sequence().isSequence(...);
    end,
    pop_front = function(...)
        return Proxy.Modules.Sequence().pop_front(...);
    end,
    push_back = function(...)
        return Proxy.Modules.Sequence().push_back(...);
    end,
    pop_front = function(...)
        return Proxy.Modules.Sequence().pop_front(...);
    end,
    pop_back = function(...)
        return Proxy.Modules.Sequence().pop_back(...);
    end,
}

Proxy.Table = {
    isTable = function(...)
        return Proxy.Modules.Table().isTable(...);
    end,
    getSize = function(...)
        return Proxy.Modules.Table().getSize(...);
    end,
    pack = function(...)
        return Proxy.Modules.Table().pack(...);
    end,
    unpack = function(...)
        return Proxy.Modules.Table().unpack(...);
    end,
    pop_front = function(...)
        return Proxy.Modules.Table().pop_front(...);
    end,
}


-------------------------------------------------------------------------------------------------
-- [[ ���� ]]
-------------------------------------------------------------------------------------------------


return Proxy;