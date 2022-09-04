---
--- @author zsh in 2022/9/4 22:55
--- Э��

-- ���ǲ���������Ҫ�õ�Э�̣����ǵ���Ҫ��ʱ��Э�̻���һ�ֲ��ɱ�������á�

--[[
    coroutine.create(...); -- ����������������Э�̣����� thread���������ڹ���״̬
    coroutine.status(...); -- ������thread�����Э�̵�״̬��
    coroutine.resume(...); -- ������thread�������������ٴ�����һ��Э�̵�ִ�У�������״̬�ɹ����Ϊ���С�
    coroutine.yield(...); -- ����Э�̵�ǿ��֮���ĺ������ú���������һ�������е�Э�̹����Լ�

    Lua ���Ե�һ���ǳ����õĻ����ǣ�ͨ��һ�� resume-yield ���������ݣ�
    1����һ�� coroutine.resume(co,...) �����״�����Э�̵��Ǹ� resume����
    ������ж������(...)���ݸ�Э�̵�������

    2��coroutine.resume �ķ���ֵ��false + message ���� true + ��Ӧ���� yield �Ĳ���
]]

-- ʹ�ù������������ߺ�������

-- ����ģ���ռ����
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

---@param prod thread @ ������
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

---���������������ߣ����������ߣ��������һЩ�����ݽ���ĳ�ֱ任�����񣨴����ˣ�
---���������������ߵ���Ϣ��Ȼ�󽫴�������Ϣ���ݸ������ߡ�
function filter(prod)
    return coroutine.create(function()
        for currentline = 1, math.huge do
            -- ������Ϣ
            local msg = receive(prod);
            if (msg == 'EOF') then
                send(msg);
                return;
            end

            --������Ϣ
            -- %5d: �����ְ����Ϊ 5�������Ҷ��뷽ʽ�����������λ������ 5 λ������߲��ո�
            local new_msg = string.format('%5d %s',currentline,msg);

            -- ������Ϣ
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