---
--- @author zsh in 2022/9/3 6:00
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分


-- 模块初始化
local File = {};
local self = File;

---@param filepath string
function File.readwholefile(filepath)
    local file, msg = io.open(filepath);
    if (not file) then
        print(msg);
        return nil;
    else

    end
end

---@param mode string @ 默认 'w'
function File.writefile(filepath, content, mode)
    mode = mode or 'w';
    local f, msg = io.open(filepath, mode);
    if (not f) then
        print('write failed!', msg);
    else
        --[[        -- Test code
                print(tostring(f)); -- file (00000000006FED50)]]

        f:write(content);
        f:flush();
        f:close();
        return true;
    end
end

---`[待改进]`判断文件是否存在（没有什么简单的方法，一般就是：试着去打开这个文件）
---@param filepath string @文件路径
function File.exists(filepath)
    local file, msg = io.open(filepath);
    if (file) then
        file:close();
        return true;
    else
        print('File.exists --> ERROR', msg);
        return false;
    end
end

---`[待改进]`获得文件大小，单位字节
---@param file_or_path userdata|string @io.open(filename)返回的流对象或者文件路径
---@return number @文件大小，单位 B
function File.getSize(file_or_path)
    if (type(file_or_path) ~= 'string' or type(file_or_path) ~= 'userdata') then
        error(string.format("Invalid variable type '%s', expected '%s'.", type(file_or_path), 'string|userdata'));
    end

    if (type(file_or_path) == 'string') then
        local f, msg = io.open(file_or_path, 'r');
        if (not f) then
            --io.stderr:write(error_msg, '\n');
            print(msg);
            return nil;
        else
            local size = f:seek('end');
            f:close();
            return size;
        end
    else
        local file = file_or_path;
        local current = file:seek();
        local size = file:seek('end');
        file:seek('set', current);
        return size;
    end
end



-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------
---`[弃用]`获得当前已被使用的内存
---@param unit_conversion boolean @是否转换单位，默认转换为 字节 B|byte（不是 bit，1B = 8bit）
---@return number @默认单位 `B`，即 字节。单位 `KB`，即：千字节
function File.getUsedMemory(unit_conversion)
    return unit_conversion ~= false and collectgarbage('count') * 1024 or collectgarbage('count');
end

--[[-- Test code ???
collectgarbage("stop")
print(File:getUsedMemory(false));
local s = File:getUsedMemory();
--local a = {}; -- 32 B ?
--local b = function()  end; -- 16 B ?
local c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
local e = File:getUsedMemory();
print((e - s));]]

return File;