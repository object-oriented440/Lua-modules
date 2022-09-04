---
--- @author zsh in 2022/9/3 5:44
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
require('debug'); -- 显式加载一下调试库
print('The debug library is used');

-- 模块初始化
local Debug = {};
local self = Debug;

---根据函数名，搜索运行栈中的所有函数，依次打印其 localvalue 的名和值
---@param func_name string @ 运行栈中的某个函数的名字
function Debug.printAllLocalValue(func_name)
    ---@type DebugInfo
    local func_data; -- 这样是否能够节省空间？不需要多次声明临时变量
    local success = false;

    for level = 2, math.huge do
        func_data = debug.getinfo(level, 'n')
        if (not func_data) then
            break ;
        elseif (func_data.name == func_name) then
            -- Test code
            --print(type(func_data.name));
            local k, v;
            for index = 1, math.huge do
                k, v = debug.getlocal(level, index);
                if (not k) then
                    break ;
                else
                    print('[' .. index .. ']', tostring(k) .. ' - ' .. tostring(v));
                    success = true;
                end
            end
        end
    end
    if (not success) then
        print('Debug.printAllLocalValue --> not found');
    end

    return success;
end

---根据函数名，搜索运行栈中的所有函数，依次打印其 upvalue 的名和值
---@param func_name string @ 运行栈中的某个函数的名字
function Debug.printAllUpValue(func_name)
    ---@type DebugInfo
    local func_data;
    local success = false;

    for level = 2, math.huge do
        func_data = debug.getinfo(level, 'nf');
        if (not func_data) then
            break ;
        elseif (func_data.name == func_name and func_data.func) then
            local func = func_data.func;
            local k, v;
            for index = 1, math.huge do
                k, v = debug.getupvalue(func, index);
                if (not k) then
                    break ;
                else
                    print('[' .. index .. ']', tostring(k) .. ' - ' .. tostring(v));
                    success = true;
                end
            end
        end
    end
    if (not success) then
        print('Debug.printAllUpValue --> not found');
    end

    return success;
end

---根据函数名，检索所有运行栈，找出第一个名字为 `local_name` 的变量，返回其值，未找到返回 nil
---@param flag any @ 留空即可
function Debug.getlocalvalue(func_name, local_name, flag)
    ---@type DebugInfo
    local func_data;

    for level = 2, math.huge do
        func_data = debug.getinfo(level, 'n');
        if (not func_data) then
            break ;
        elseif (func_data.name == func_name) then
            local k, v;
            for index = 1, math.huge do
                k, v = debug.getlocal(level, index);
                if (not k) then
                    break ;
                elseif (k == local_name) then
                    if (flag == 'setlocalvalue') then
                        return v, level, index;
                    else
                        return v;
                    end
                end
            end
        end
    end
    print('Debug.getlocalvalue --> not found');
    return nil;
end

---根据函数名，检索所有运行栈，将第一个名字为 `local_name` 的变量赋予新值
function Debug.setlocalvalue(func_name, local_name, new_value)
    local localvalue, level, index = self.getlocalvalue(func_name, local_name, 'setlocalvalue');
    if (localvalue and level and index) then
        -- NOTE: getlocalvalue 调用完毕出栈，因此 level 要 -1
        debug.setlocal(level - 1, index, new_value);
        return true;
    end
    print('Debug.setlocalvalue --> setup failed');
end

---根据函数名，检索所有运行栈，找出第一个名字为 `upvalue_name` 的变量，返回其值，未找到返回 nil
---@param flag any @ 留空即可
function Debug.getupvalue(func_name, upvalue_name, flag)
    ---@type DebugInfo
    local func_data;

    for level = 2, math.huge do
        func_data = debug.getinfo(level, 'nf');
        if (not func_data) then
            break ;
        elseif (func_data.name == func_name and func_data.func) then
            local func = func_data.func;
            local k, v;
            for index = 1, math.huge do
                k, v = debug.getupvalue(func, index);
                if (not k) then
                    break ;
                elseif (k == upvalue_name) then
                    if (flag == 'setupvalue') then
                        return v, func, index;
                    else
                        return v;
                    end
                end
            end
        end
    end
    print('Debug.getupvalue --> not found');
    return nil;
end

---根据函数名，检索所有运行栈，将第一个名字为 `upvalue_name` 的变量赋予新值
function Debug.setupvalue(func_name, upvalue_name, new_value)
    local upvalue, func, index = self.getupvalue(func_name, upvalue_name, 'setupvalue');
    if (upvalue and func and index) then
        -- tips: param1, f:number|function
        debug.setupvalue(func, index, new_value);
        return true;
    end
    print('Debug.setupvalue --> setup failed');
end

--[[do
    -- Test code: set\get localvalue\upvalue、printAll LocalValue\UpValue
    local f1, f2, f3, current;

    f1 = function()
        local f1a = 'f1a_v';
        local f1b = 'f1b_v';
        f2();
    end

    f2 = function()
        local f2a = 'f2a_v';
        local f2b = 'f2b_v';
        f3();
    end

    local f3_upvalue = 'f3_up_1';
    f3 = function()
        local f3a = 'f3a_v';
        local f3b = 'f3b_v';

        f3_upvalue = f3_upvalue;
        current();
    end

    current = function()
        self.printAllLocalValue('f3');
        print();
        self.printAllUpValue('f3');
        print();
        print(self.getlocalvalue('f3', 'f3a'));
        print();
        print(self.getupvalue('f3', 'current'));
        print();

        print(self.getlocalvalue('f3', 'f3a'));
        print(self.setlocalvalue('f3', 'f3a', 'f3a_new'))
        print(self.getlocalvalue('f3', 'f3a'));
        print();

        print(self.getupvalue('f3', 'f3_upvalue'));
        -- NOTE: 函数没有 return，tostring\type 都会：bad argument #1 to 'tostring' (value expected)
        -- NOTE: 所有我应该给每个函数都加 return ？但是 xxx == nil --> true，而 tostring(xxx) × tostring(nil) √
        print(self.setupvalue('f3', 'f3_upvalue', 'f3_upvalue_new'));
        print(self.getupvalue('f3', 'f3_upvalue'));
        print();
    end

    f1();
    --print:
    --[1]	f3a - f3a
    --[2]	f3b - f3b
    return ;
end]]

--[[do
    -- Test code
    local Table = require('chang.modules.utils.Table');
    local print = function(...)
        _G.print(...);
    end
    local func_data = debug.getinfo(print);
    Table.deepPrint(func_data);
    return ;
end]]
-------------------------------------------------------------------------------------------------
-- [[ 待实现、待完善、待修正、待舍弃 ]]
-------------------------------------------------------------------------------------------------
---`[待改进]`找到指定函数中的指定局部变量，如果找到了则返回 value
---@param func_name string @函数名
---@param local_name string @局部变量名
---@param isset nil|boolean @是否是 setlocalvalue 函数要使用的
function Debug.getlocalvalue__(func_name, local_name, isset)
    if (type(func_name) ~= 'string' and type(local_name) ~= 'string') then
        --error('< Please pass in the correct parameters >', 2);
        return nil;
    end
    local MATH_HUGE = math.huge;
    local MAX_LEVEL = 20; -- 最大回溯栈数
    local MAX_INDEX = 20; -- 最大变量索引数
    for level = 1, MAX_LEVEL do
        local info = debug.getinfo(level, 'n');
        if (info == nil) then
            -- 用 print
            --io.write('< There is no function:`', tostring(func_name), '` >\n');
            return nil;
        else
            if (info.name == func_name) then
                for i = 1, MAX_INDEX do
                    local name, value = debug.getlocal(level, i);
                    if (name == nil) then
                        --io.write('< There is no local variable `', tostring(local_name), '` in function `', tostring(func_name), '` >\n');
                        return nil;
                    end
                    if (name == local_name) then
                        --io.write('< find the local variable `', tostring(local_name), '` in function `', tostring(func_name), '` >\n');
                        if (isset) then
                            return value, level, i;
                        end
                        return value;
                    end
                end
            end
        end
    end
    --io.write('< MAX_LEVEL:', tostring(MAX_LEVEL), ', MAX_INDEX:', MAX_INDEX, ' >\n');
    --io.write('< cannot find the local variable `', tostring(local_name), '` in function `', tostring(func_name), '` >\n');
    return nil;
end

---`[待改进]`设置指定函数中的指定局部变量的值（如果找到的话）
---@param func_name string
---@param local_name string
---@param new_value any @新值
function Debug.setlocalvalue__(func_name, local_name, new_value)
    if (type(func_name) ~= 'string' or type(local_name) ~= 'string') then
        --error('< Please pass in the correct parameters! >', 2);
        return nil;
    end
    local value, level, i = self.getlocalvalue(func_name, local_name, true);
    if (level and i) then
        debug.setlocal(level - 1, i, new_value) -- level - 1 ！！！
    end
end

---`[待改进]`找到指定函数/闭包的指定变量，如果找到了就返回 value
---@param func_name string @闭包名
---@param upvalue_name string @变量名
---@param isset nil|boolean @是否是 setupvalue 函数要使用的
function Debug.getupvalue__(func_name, upvalue_name, isset)
    if (type(func_name) ~= 'string' or type(upvalue_name) ~= 'string') then
        --error('< Please pass in the correct parameters! >', 2);
        return nil;
    end
    local MATH_HUGE = math.huge;
    local MAX_LEVEL = 20; -- 最大回溯栈数
    local MAX_INDEX = 20; -- 最大变量索引数
    for level = 1, MAX_LEVEL do
        local info = debug.getinfo(level, 'nf');
        if (info == nil) then
            --io.write('< There is no function/closure:`', tostring(func_name), '` >\n');
            return nil;
        else
            if (info.name == func_name) then
                for i = 1, MAX_INDEX do
                    local name, value = debug.getupvalue(info.func, i);
                    if (name == nil) then
                        --io.write('< There is no upvalue `', tostring(upvalue_name), '` in function/closure `', tostring(func_name), '` >\n');
                        return nil;
                    end
                    if (name == upvalue_name) then
                        --io.write('< find the upvalue `', tostring(upvalue_name), '` in function/closure `', tostring(func_name), '` >\n');
                        if (isset) then
                            return value, info.func, i;
                        end
                        return value;
                    end
                end
            end
        end
    end
    --io.write('< MAX_LEVEL:', tostring(MAX_LEVEL), ', MAX_INDEX:', MAX_INDEX, ' >\n');
    --io.write('< cannot find upvalue `', tostring(upvalue_name), '` in function `', tostring(func_name), '` >\n');
    return nil;
end

---`[待改进]`设置指定函数中的指定局部变量的值（如果找到的话）
---@param func_name string
---@param upvalue_name string
---@param new_value any @新值
function Debug.setupvalue__(func_name, upvalue_name, new_value)
    if (type(func_name) ~= 'string' or type(upvalue_name) ~= 'string') then
        --error('< Please pass in the correct parameters! >', 2);
        return nil;
    end
    local value, func, i = self.getupvalue(func_name, upvalue_name, true);
    if (func and i) then
        debug.setupvalue(func, i, new_value);
    end
end

-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------
-- TODO:待完善，建议直接使用调试库提供的 debug.traceback（字符串） 改进版本
---`[待完善]` 打印 调用该函数时 的活跃栈的栈回溯
function Debug.traceback()
    for level = 1, math.huge do
        local info = debug.getinfo(level, 'Sl');
        if (info == nil) then
            break ;
        end

        if (info.what == 'C') then
            print(string.format('%d\tC function', level));
        else
            print(string.format('%d\t[%s]:%d', level, info.short_src, info.currentline));
        end
    end
end

return Debug;