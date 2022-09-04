---
--- @author zsh in 2022/8/9 6:25
---

_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });


local Util = {};


---给 enterTable 函数提供的，变量不同类型处理不同的逻辑
---@vararg string
--[[local function handleTypeLogic(...)
    if (type(k) == 'string') then
        io.write(string.format(...),'\n');
    else
        io.write(string.format(...),'\n');
    end
end]]

--[[---遍历整张表并输出表中内容的递归函数
---@field tab table @某张表
---@field n number @表的层数，默认为 1
local function enterTable(tab, n)

    -- 获得缩进
    local indentation = '';
    for i = 1, n do
        indentation = indentation .. '    ';
    end

    if (n == 1) then
        print('{');
    end

    -- 递归条件：遍历整张表
    local cnt = 0;
    for k, v in pairs(tab) do
        cnt = cnt + 1;
        if not (type(k) == 'string' and string.match(k, '^__')) then
            if (type(v) ~= 'table') then
                if (cnt ~= Util:getTableLength(tab)) then
                    if (type(k) == 'string') then
                        print(string.format(indentation .. '[\"%s\"] = %s,', tostring(k), tostring(v)));
                    else
                        print(string.format(indentation .. '[%s] = %s,', tostring(k), tostring(v)));
                    end
                    --print(string.format(indentation .. '%s = %s,', tostring(k), tostring(v)));
                else
                    if (type(k) == 'string') then
                        print(string.format(indentation .. '[\"%s\"] = %s,', tostring(k), tostring(v)));
                    else
                        print(string.format(indentation .. '[%s] = %s,', tostring(k), tostring(v)));
                    end
                    --print(string.format(indentation .. '%s = %s', tostring(k), tostring(v)));
                end
            else
                if (type(k) == 'string') then
                    print(string.format(indentation .. '[\"%s\"] = ' .. '{', tostring(k)));
                else
                    print(string.format(indentation .. '[%s] = ' .. '{', tostring(k)));
                end
                enterTable(v, n + 1);
                if (cnt ~= Util:getTableLength(tab)) then
                    print(indentation .. '},');
                else
                    print(indentation .. '}');
                end
            end
        end
    end

    if (n == 1) then
        print('}');
    end
end]]

--[[ package ]]
---修改 package.path （package.loaded 是模块字典）
---@param requireAbsolutePath string @require 加载模块
function Util:addPackagePath(requireAbsolutePath)
    local oldPath = package.path;
    package.path = oldPath .. ';' .. requireAbsolutePath;
end

---修改 package.cpath
---@param requireAbsolutePath string @require 加载模块
function Util:addPackageCPath(requireAbsolutePath)
    local oldCPath = package.cpath;
    package.path = oldCPath .. ';' .. requireAbsolutePath;
end

function Util:printPackagePath()
    for e in string.gmatch(package.path, '[^;]+') do
        io.write(e, '\n');
    end
end

function Util:printPackageCpath()
    for e in string.gmatch(package.cpath, '[^;]+') do
        io.write(e, '\n');
    end
end

function Util:printPackagePreload()
    self:printTable(package.preload);
end

function Util:printPackageLoaded()
    self:printTable(package.loaded);
end

--[[---判断变量是否为 table 类型
---@param tab table
function Util:isTable(tab)
    return type(tab) == 'table';
end

---遍历某个表，然后按照一定格式输出其中的内容
---@param tab table
function Util:printTable(tab)
    if (not self:isTable(tab)) then
        io.write(tostring(tab), '\n');
        return ;
    end
    local msg = {};

    for k, v in pairs(tab) do
        if (type(k) == 'string') then
            table.insert(msg, '[\"' .. tostring(k) .. '\"] = ' .. tostring(v) .. '\n');
        else
            table.insert(msg, '[' .. tostring(k) .. '] = ' .. tostring(v) .. '\n');
        end
    end

    local str = table.concat(msg);

    print(str);
end

-- FIXME:不允许存在共享的子表和环（环：表中存自身）
---打印表内的所有内容
---@param tab table
function Util:printTableAll(tab)
    if (not self:isTable(tab)) then
        io.write(tostring(tab), '\n');
        return ;
    end
    enterTable(tab, 1);
end]]

--[[---浅拷贝表
function Util:cloneTable(tab)
    local c = {};
    for k, v in pairs(tab) do
        c[k] = v;
    end
    return c;
end

---深拷贝表
function Util:cloneTableAll(tab)
    if (not self:isTable(tab)) then
        return tab;
    end
    local c = {};
    for k, v in pairs(tab) do
        c[k] = self:cloneTableAll(v);
    end
    return c;
end

---获取表的长度
---@param tab table @表
---@return number @表的长度
function Util:getTableLength(tab)
    if (not self:isTable(tab)) then
        print('param is not a table type');
        return 0;
    end
    local length = 0;
    for k, v in pairs(tab) do
        length = length + 1;
    end
    return length;
end]]

-- FIXME:打印错误信息
---@vararg string
function Util:printErrorInfo(...)
    --local getinfo0 = debug.getinfo(0); -- getinfo 自身
    local getinfo1 = debug.getinfo(1); -- 调用 getinfo 的函数 f1
    local getinfo2 = debug.getinfo(2); -- 调用 f1 的函数 f2（其他：，...以此类推。f1, f2, ...也可能不是函数，而是在文件中直接调用getinfo））

    ---@todo 传入参数必须为字符串?
    for _, v in ipairs({ ... }) do
        if (not (type(v) == 'string') and
                not (type(v) == 'number')) then
            io.stderr:write('path:', tostring(getinfo1.source), ', ',
                    'function:', tostring(getinfo1.name), ', ',
                    'line:', tostring(getinfo1.currentline), ', ',
                    'error: `',
                    'please attempt to use the \'tostring\' function',
                    '`;\n');
            io.stderr:flush();
            return ;
        end
    end

    io.stderr:write('path:', tostring(getinfo2.source), ', ',
            'function:', tostring(getinfo2.name), ', ',
            'line:', tostring(getinfo2.currentline), ', ',
            'error: `',
            #{ ... } == 0 and 'undefined error' or ...,
            '`;\n');
    io.stderr:flush();
end

--[[---获取字符串的长度
function Util:getStringLength(s)
    if (not (type(s) == 'string')) then
        self:printErrorInfo('param is not a string type');
        return nil;
    end
    --local s1 = os.time();
    local length = #s;
    --local e1 = os.time();
    --io.write('length:', length, ',total time:', (e1 - s1), ' milliseconds\n');

    if (false) then
        -- 我的获取字符串长度的方法
        -- 20MB 文件读取耗时 2 毫秒
        local s2 = os.time();
        local cnt = 0;
        for _ in string.gmatch(s, '.') do
            cnt = cnt + 1;
        end
        local e2 = os.time();
        length = cnt;
        io.write('length:', length, ',total time:', (e2 - s2), ' milliseconds\n');
    end

    return length;
end]]





return Util;
