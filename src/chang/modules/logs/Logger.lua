---
--- @author zsh in 2022/8/18 13:53
---

_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
local Class = require('m3.chang.modules.utils.Class');
local File = require('m3.chang.modules.utils.File');

local LogTarget = {
    file = 'file',
    terminal = 'terminal',
    terminal_and_file = 'terminal_and_file'
};

local LogLevel = {
    debug = 'debug',
    info = 'info',
    warning = 'warning',
    error = 'error'
};

---按照一定的格式获得当前时间
---@return string
local function currentTime()
    return os.date('%Y-%m-%d %H:%M:%S');
end

---@param stackLevel number @栈层次
local function getFilePath(stackLevel)
    local func_data = debug.getinfo(stackLevel, 'S');
    local short_src = func_data.short_src;
    --local filename = string.sub(short_src, string.find(short_src, '[^/|\\]*$'));
    return short_src;
end

---输出到控制台
---@param text string @输出内容
local function outToTerminal(text)
    print(text);
end

---输出到文件
---@param path string @文件路径
---@param text string
local function outToFile(path, text)
    local mode = 'a';
    if (File:getFileSize(path) == 100 * 1024) then
        mode = 'w';
    end
    local file = io.open(path, mode);
    if (file) then
        file:write(text, '\n');
        --file:flush();
        file:close();
    else
        --io.stderr:write('file opening failed, please check the file path!');
        print('file opening failed, please check the file path!');
    end
end

---输出
---@param self table
---@param act_level string|"'debug'"|"'info'"|"'warning'"|"'error'"
---@param text string @日志内容
local function output(self, act_level, text)
    local prefix = '';

    do
        local condition = act_level;
        local switch = {
            [LogLevel.debug] = function()
                prefix = '[debug]   ';
            end,
            [LogLevel.info] = function()
                prefix = "[info]    ";
            end,
            [LogLevel.warning] = function()
                prefix = "[warning] ";
            end,
            [LogLevel.error] = function()
                prefix = "[error]   ";
            end
        };
        if (switch[condition]) then
            switch[condition]();
        else
            -- default
        end
    end

    local output_content = prefix .. '[' .. getFilePath(4) .. ']   ' .. currentTime() .. ' : ' .. text;

    do
        local condition = self.logTarget;
        local switch = {
            [LogTarget.terminal] = function()
                outToTerminal(output_content);
            end,
            [LogTarget.file] = function()
                outToFile(self.path, output_content);
            end,
            [LogTarget.terminal_and_file] = function()
                outToTerminal(output_content);
                outToFile(self.path, output_content);
            end
        };
        if (switch[condition]) then
            switch[condition]();
        else
            outToTerminal(output_content);
        end
    end
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---@class Logger @日志类
---@field path string @日志输出路径
---@field logTarget string@日志输出目标：控制台、文件、控制台和文件
local Logger = Class(function(self, path, logTarget)
    self.logTarget = logTarget or 'file';
    if (path == nil) then
        --io.stderr:write('ERROR!!! path is nil');
        print('ERROR!!! path is nil');
    end
    self.path = path
end)

---@param path string
---@param logTarget string|"'terminal'"|"'file'"|"'terminal_and_file'"
function Logger:create(path, logTarget)
    return Logger(path, logTarget);
end

function Logger:tostring()
    return '{ path: ' .. tostring(self.path)
            .. ', logTarget: ' .. tostring(self.logTarget)
            .. ' }';
end

local function safety(self, text)
    if (type(self) ~= 'table' and type(text) ~= 'string') then
        local func_data = debug.getinfo(3, 'Sl');
        print('`self == nil`', '[' .. func_data.short_src .. ']', func_data.currentline);
        return false;
    end
    return true;
end

function Logger:log(text)
    if (not safety(self, text)) then
        return ;
    end
    output(self, '', text);
end

function Logger:debug(text)
    if (not safety(self, text)) then
        return ;
    end
    output(self, 'debug', text);
end

function Logger:info(text)
    if (not safety(self, text)) then
        return ;
    end
    output(self, 'info', text);
end

function Logger:warning(text)
    if (not safety(self, text)) then
        return ;
    end
    output(self, 'warning', text);
end

function Logger:error(text)
    if (not safety(self, text)) then
        return ;
    end
    output(self, 'error', text);
end

return Logger;