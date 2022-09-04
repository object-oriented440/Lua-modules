---
--- @author zsh in 2022/9/3 14:25
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
local Assertion = require('chang.modules.utils.Assertion');

-- 模块初始化
local String = {};
local self = String;

--[[
    魔法字符： ( ) . % + - * ? [ ] ^ $

    .       任意字符
    %a      字母
    %c      控制字符
    %d      数字
    %g      除空格外的可打印字符
    %l      小写字母
    %p      标点符号
    %s      空白字符
    %u      大写字母
    %w      字母和数字
    %x      十六进制数字

    %b      匹配成对的字符串，如 `%b()` 匹配以左括号开始并以对应右括号结束的子串
    ^       从目标字符串开头开始匹配
    $       匹配到目标字符串的结尾


    string.byte(s, i, j)
    string.char(...)
    string.dump(func, strip)

    string.find(s, pattern, init, plain)
    string.format(formatstring, ...)
    string.gmatch(s, pattern)
    string.gsub(s, pattern, repl, n)
    string.match(s, pattern, init)
    string.sub(s, i, j)

    string.pack(fmt, v1, v2, ...)
    string.unpack(fmt, s, pos)
    string.packsize(fmt)

    string.rep(s, n, sep)
    string.reverse(s)

    string.len(s)
    string.lower(s)
    string.upper(s)
]]


function String.isString(v)
    return type(v) == 'string';
end

---剔除字符串两端的空格
---@param s string  字符串
---@return string   替换后的字符串
function String.trimSpace(s)
    -- '^%s*(.*)%S$'
    local str, _ = string.gsub(s, '^%s*(.-)%s*$', '%1'); -- 注意：- 这个字符
    return str;
end

function String.getLength(s)
    if (type(s) ~= 'string') then
        return 0;
    end
    return #s;
end


-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return String;