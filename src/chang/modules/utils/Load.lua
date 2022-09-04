---
--- @author zsh in 2022/9/3 6:06
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
local Table = require('chang.modules.utils.Table');

-- 模块初始化
local Load = {};
local self = Load;

---nil: 文件不存在，string：编译失败，function：文件存在，无语法错误，可尝试加载
---@param path string
---@return nil|string|function
function Load.loadfile(path)
    local f, msg = loadfile(path);
    if (not f) then
        print('Load.loadfile --> ERROR', msg);
        if (string.find(msg, 'No such file or directory')) then
            return nil;
        end
        return msg;
    end
    return f;
end

-- 关于 pcall
-- 1、f 是可以构成闭包的，也可以通过传参的方式，arg1,... 就是 f 的参数
-- 2、pcall 是安全模式，正常执行，知道错误发生，pcall 终止，但不会报错！

---保护模式调用函数 f，若执行正常，则返回 f 的全部结果，否则返回 nil
---@param f function
function Load.pcall(f, arg1, ...)
    local args = Table.pack(pcall(f, arg1, ...));
    local ok = args[1];
    local results = Table.pop_front(args);

    if (not ok) then
        print('Load.pcall --> ERROR', results[1]);
        return nil;
    else
        return Table.unpack(results);
    end
end

--[[do
    -- Test code
    print(Load:changpcall(function(...)
        a = 'a';
        b = a * c;
        return 'a', 'b', 'c', ...;
    end, 1, 2, 3, 4, 5));
end]]

---类似 changpcall 相同，只是多了个消息处理程序 `msgh`
---@param f function
---@param msgh function
function Load.xpcall(f, msgh, arg1, ...)
    local old_msgh = msgh;
    msgh = function(msg--[[虽然参数只有一个，但是可以构成闭包呀！]])
        -- 注意这样是错误的，可变长参数需要在外部转成表然后构成闭包使用！
        -- print('msgh >',...);
        print('Load.xpcall --> ERROR', msg);
        if (old_msgh and type(old_msgh) == 'function') then
            old_msgh(msg);
        end
    end

    -- NOTE: 直接返回 status 和 所有返回值！msg 传给了 msgh，不返回了！
    local results = Table.pack(xpcall(f, msgh, arg1, ...));

    if (not results[1]) then
        return nil;
    end

    return Table.unpack(Table.pop_front(results));
end

--[[do
    Load.xpcall(function()
        a = a + 1;
    end, nil, 1, 2, 3);
    return ;
end]]

--[[do
    -- Test code
    print(Load:changxpcall(function(...)
        --a = 'a';
        --b = a * c;
        return 'a', 'b', 'c', ...;
    end, nil, 1, 2, 3, 4, 5));
end]]

-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------
-- 如果已经找不到更简单的解决方法后，再使用 load 函数
-- 尽管函数 load 的功能很强大，但还是应该谨慎地使用。因为相对于其他可选的函数而言，
-- 该函数的开销较大并且可能会引起诡异的问题。
---`[弃用、待改进]`编写一个用后即弃的 dostring 函数
function Load.dostring(chunk, chunkname, mode, env)
    env = env or _G; -- 避免设置模块独占环境后，出现问题！（没必要，env 默认是 全局环境 _G）
    local f, msg = load(chunk, chunkname, mode, env);
    if (not f) then
        print('ERROR', msg);
    else
        return f();
    end

    --assert(load(chunk, chunkname, mode, env))();
end

--[[do
    -- Test code
    i = 0;
    ---@language Lua
    local f, msg = load([=[
        i=i+1;
    ]=], nil, nil, _ENV);
    f();

    print(i);

    env = 'test';
    local f,msg = load(function()
        _ENV = _G;

    end)

    print(env);
end]]

-- FIXME: dst 的 Lua 版本为 5.1，之后将 EmmyLua 的 language level 改为 5.1，不然不安全
-- TODO: 去了解一下 dofile、load、loadfile、pcall、pxcall 里面的代码的环境是否和外部一样（是否同样可以构成闭包！），
-- TODO: 执行时是否可以修改内存数据！（比如全局表，或者局部变量！）
---`[待实现、待修正、弃用]`
function Load.ploadcall(chunk, chunkname, mode, env, arg1, ...)
    -- 直接将环境设置成 _G，因为没弄懂饥荒的模组的 env 环境（其实更多还是 Lua 的 _ENV 似乎弄的不是太懂），
    -- load 函数说是：默认为全局环境，所以这个全局环境指的是不是 _G 呢？
    -- _G 是什么呢？绝对全局环境？
    env = env or _G;

    local f, msg = load(chunk, chunkname, mode, env);

end

--[[do
    -- Test code
    -- _ENV = _G;
    local x = 2;
    -- Test code
    local f, msg = load('print("hello");print(_ENV.x);x=1;');
    print(f);
    f();
    print(x);
    return ;
end]]

--[[do
    -- Test code
    -- 假设 do ... end 为一个独立环境，那么 load 里面访问的就是 _G ！
    -- 但是由于我设置了 _ENV，所以 i 不是 _G 里面的 i，而是 _ENV 里面的 i
    -- 所以 _G 才是真正的全局变量，而我设置的 _ENV 为局部全局变量！
    local f = load('i=i+1');

    -- 下面对
    _G.i=0;
    f();print(_G.i);
    f();print(_G.i);
    -- 主动设置了 _ENV 后，下面报错（默认 _ENV = _G 的！）
    i=0;
    f();print(i);
    f();print(i);
    return;
end]]

return Load;