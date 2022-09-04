---
--- @author zsh in 2022/9/3 14:31
---

-- 设置模块独占环境
_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

-- 导入部分


-- 模块初始化
local IO = {};
local self = IO;

---`[待修正]`
function IO.fwrite(fmt, ...)
    return io.write(string.format(fmt, ...)); -- type: userdata
end




-------------------------------------------------------------------------------------------------
-- [[ 弃用 ]]
-------------------------------------------------------------------------------------------------


return IO;