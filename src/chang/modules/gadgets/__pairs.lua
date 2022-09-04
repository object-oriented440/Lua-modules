---
--- @author zsh in 2022/8/21 13:51
---

-- 不应该放在 modules/utils.txt 目录下

---允许某个表中存在值为 nil 的变量？
---遍历某个表可以输出 nil
local __declared = {};

--[[local function searchNil(s, var)
    -- 不可变状态和控制变量
    ]]--[[    local next_k, value;
        if (var == nil) then
            next_k, value = next(s, var);
            var = next_k;
            return next_k, value;
        end
        next_k, value = next(s, var);]]--[[

    return next(s, var);
end]]

local count = 0;
local mt = {
    --[[    __index = function(child, k)

        end,]]
    __newindex = function(child, k, v)
        count = count + 1;
        print('__newindex count: ' .. count);
        if (not __declared[k]) then
            __declared[k] = true;
        end
        rawset(child, k, v);
    end,
    __pairs = function(child)
        return function(_s, _var)
            local next_k, value = next(_s, _var);
            return next_k, child[next_k];
        end, __declared, nil;
    end
};

local a = setmetatable({}, mt);
a[1] = 1;
a[2] = nil;
a['a'] = 'a';
a[3] = 3;
a[{}] = nil;

for k, v in pairs(a) do
    print(k, v);
end
 