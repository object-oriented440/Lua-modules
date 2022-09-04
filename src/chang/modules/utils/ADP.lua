---
--- @author zsh in 2022/9/3 14:10
---

-- ADP: The Acyclic Dependencies Principle，非循环依赖原则
-- 本模块为公用模块，暂时用来解决其他模块的循环引用问题！

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分
-- 不能有其他依赖

-- 模块初始化
local ADP = {};
local self = ADP;

---`[utils/Table.lua]`判断：中间不存在空洞的表！纯列表！
---@return boolean
function ADP.isSequence(t)
    if (type(t) ~= 'table') then
        return false;
    end

    local list_index = {};
    for k, _ in pairs(t) --[[nil 也赋序号]] do
        if (type(k) == 'number') then
            table.insert(list_index, k);
        end
    end

    table.sort(list_index);

    local length = #list_index;
    if (list_index[length] == length) then
        return true;
    end

    return false;
end



-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return ADP;
 