---
--- @author zsh in 2022/9/4 22:55
--- 协程

-- 我们并不经常需要用到协程，但是当需要的时候，协程会起到一种不可比拟的作用。

--[[
    coroutine.create(...); -- 参数：函数。创建协程，返回 thread，创建后处于挂起状态
    coroutine.status(...); -- 参数：thread。检查协程的状态。
    coroutine.resume(...); -- 参数：thread。用于启动或再次启动一个协程的执行，并将其状态由挂起改为运行。
    coroutine.yield(...); -- 体现协程的强大之处的函数，该函数可以让一个运行中的协程挂起自己

    Lua 语言的一个非常有用的机制是：通过一对 resume-yield 来交换数据，
    1、第一个 coroutine.resume(co,...) （即首次启动协程的那个 resume），
    会把所有额外参数(...)传递给协程的主函数

    2、coroutine.resume 的返回值：false + message 或者 true + 对应函数 yield 的参数
]]

-- 使用过滤器的生产者和消费者

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

---@param prod thread @ 生产者
function receive(prod)
    local status, value = coroutine.resume(prod);
    if (not status) then
        print('states:', coroutine);
        print('value:', value);
    end
    return value;
end

function send(msg)
    coroutine.yield(msg);
end

function producter()
    return coroutine.create(function()
        while (true) do
            io.write('please input a line:');
            io.flush();
            local msg = io.read();
            send(msg);
        end
    end)
end

---过滤器即是生产者，又是消费者，用于完成一些对数据进行某种变换的任务（代理人）
---过滤器接收生产者的消息，然后将处理后的消息传递给消费者。
function filter(prod)
    return coroutine.create(function()
        for currentline = 1, math.huge do
            -- 接收消息
            local msg = receive(prod);
            if (msg == 'EOF') then
                send(msg);
                return;
            end

            --处理消息
            -- %5d: 将数字按宽度为 5，采用右对齐方式输出，若数据位数不到 5 位，则左边补空格
            local new_msg = string.format('%5d %s',currentline,msg);

            -- 发送消息
            send(new_msg);
        end
    end)
end

local filename = 'exercises/Coroutine.txt';
local outfile = assert(io.open(filename,'a'));
function consumer(proxy)
    while (true) do
        local msg = receive(proxy);
        if (msg == 'EOF') then
            return;
        end
        outfile:write(msg,'\n');
        outfile:flush();
    end
end


consumer(filter(producter()));

outfile:close();
print('coroutine task over');