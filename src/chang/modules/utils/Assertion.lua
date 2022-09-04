---
--- @author zsh in 2022/9/3 5:26
---

-- 断言是用来检查非法情况而不是错误情况的，用来帮开发者快速定位问题的位置。

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
-- 注意，Assertion 用于基本会被所有文件使用，所以必须保证它的高内聚性！除了公共模块，不允许与其他模块有耦合！
local ADP = require('chang.modules.utils.ADP');

-- 模块初始化
local Assertion = {};
local self = Assertion;

---@param v any 变量
---@param whatType string|"'sequence'"|"'list'" 需要判断是什么类型？
---@param stackLevel number|"'1'"|"'2'"|"'3'"|"'etc...'"
function Assertion.isType(v, whatType, stackLevel)
    -- 避免传入空值？注意这个空值不是 nil，而是 `return;` 这种形式被 type 接收！
    -- 但是 nil 和 false 才为 false，这个空值到底是什么呢？还是这只是个 bug？
    v = v or nil;

    local level = stackLevel or 3;

    local string_error_msg = string.format("Invalid variable type '%s', expected '%s'.", type(whatType), 'string');
    local other_error_msg = string.format("Invalid variable type '%s', expected '%s'.", type(v), whatType);

    if (type(whatType) ~= 'string') then
        error(string_error_msg, level);
    elseif (type(v) ~= whatType) then
        error(other_error_msg, level);
    end

    return true;
end

--[[do
    -- Test code: type() `bad argument #1 to 'type' (value expected)`
    local test = function()
        return ;
    end;
    local a = test();
    io.write('{', tostring(a), '}\n');
    io.flush();
    print(type(a)); -- test() 返回 空气 给 a，a 自动赋值了 nil
    print(type(test())); -- 这种情况，`bad argument #1 to 'type' (value expected)`
end]]

return Assertion;


