---
--- @author zsh in 2022/9/3 7:14
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分


-- 模块初始化
local Math = {};
local self = Math;

-- FIXME: p23
---`[待完善、待修正]`向最近的整数取整
---@return number
function Math.round(x)
    return math.floor(x + 0.5); -- 不够完善
end

---保留几位小数
---@return number
function Math.setPrecision(number, n)
    return number - number % tonumber('1e-' .. n);
end

---`[兼容 Lua 5.1]` Lua 5.3 的 floor 除法
---@return number
function Math.floorDivision(a, b)
    return tonumber(tostring((a - (a % b)) / b):sub(1, -3));
end

---`[待实现]`
function Math.SaturationArithmetic(x, min, max)
    if (x<min) then
        return min;
    elseif (x > max) then
        return max;
    else
        return x;
    end
end

-------------------------------------------------------------------------------------------------
-- [[ 待定 ]]
-------------------------------------------------------------------------------------------------
Math.Binary={};
Math.Octal={};
Math.Decimal={};
Math.Hexadecimal={};

local Binary = Math.Binary;
local Octal = Math.Octal;
local Decimal = Math.Decimal;
local Hexadecimal = Math.Hexadecimal;

---通用进制转换
local function commonHexBinDecOct(R1, R2, x)

end

local tmp = '';
-- FIXME:
---`[待实现、待修正]`十进制转为二进制
function Decimal.Binary(x)
    -- 假设 number 为 32 位
    --[[    do
            local str = '';
            for i = 31, 0, -1 do
                local x2 = x - 2 ^ i;
                if (x2 >= 0) then
                    str = str .. '1';
                    x = x2;
                else
                    if (str:sub(1, 1) == '1') then
                        str = str .. '0';
                    end
                end
            end
            return str;
        end]]

    do

        if (x == 0) then
            return ;
        end

        local i, r = Math.floorDiv(x, 2), x % 2;
        --print(i,r);

        self.Binary(i);

        tmp = tmp .. r;

        return tmp;
    end
end

--[[do
    -- Test code
    print(Decimal.Binary(100));
end]]

---`[待实现]`十进制转为八进制
function Decimal.Octal(x)

end

---`[待实现]`十进制转为十六进制
function Decimal.Hexadecimal(x)

end
-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return Math;