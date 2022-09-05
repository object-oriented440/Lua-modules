---
--- @author zsh in 2022/9/5 6:11
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
-- 代理模块，不允许在主程序块中导入其他模块，且此处的代码尽量都是 Lua 函数，不要在 main chunk 中执行代码！
-- 主要为了解决循环依赖问题，以及方便修改 require 的 modulename

-- 模块初始化
local Proxy = {};
local self = Proxy;

-- 代理（便于业务逻辑处引用模块）
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

-- 部分代理（便于模块内部使用，尽量解决由于头部 require 导致的循环依赖问题，因为模块内部一般并不会大量使用）
-- NOTE: 使用部分代理，基本上应该不会出现问题了。除非：A.f1 --> B.f1 --> A.f2 --> A.f1！这种情况！！！
-- NOTE: 模块的 main chunk 中请尽量不要执行代码！避免 A: main chunk --> require B --> require A --> A: main chunk ... 循环，堆栈溢出！
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
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return Proxy;