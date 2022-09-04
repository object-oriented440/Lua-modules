---
--- @author zsh in 2022/9/3 5:39
--- { link:https://zhuanlan.zhihu.com/p/76717305 }


-- Class.lua
-- 与lua 5.1兼容 (不兼容 5.0).
local function Class(base, init)
    local c = {}    -- 要返回的新的class类型
    if not init and type(base) == 'function' then
        init = base
        base = nil
    elseif type(base) == 'table' then
        -- 新的类(c)是基类(base)的浅拷贝
        for i, v in pairs(base) do
            c[i] = v
        end
        c._base = base -- type(base) == 'table'
    end
    -- 类c将会是它所有实例对象的元表(metatable)，
    -- 并且实例对象会成c中查找方法.
    c.__index = c

    -- 暴露一个构造函数，调用方式: <classname>(<args>)
    local mt = {} -- 类c的元表
    mt.__call = function(class_tbl, ...)
        -- 1. 把类c设为对象元表 2. 初始化
        local obj = {}
        setmetatable(obj, c) --把类c设为对象ob的元表
        if init then
            init(obj, ...) --这里没有调用基类的init，所以init不为空时，要在子类的init中手动调用基类的init
        else
            -- 确保基类的东西都初始化了
            if base and base.init then
                base.init(obj, ...)
            end
        end
        return obj
    end --mt.__call() 定义结束

    c.init = init
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then
                return true
            end
            m = m._base
        end
        return false
    end

    setmetatable(c, mt)
    return c
end

return Class;