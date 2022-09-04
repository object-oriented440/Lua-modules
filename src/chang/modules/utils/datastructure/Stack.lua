---
--- @author zsh in 2022/8/13 1:17
--- ջ

_ENV = { _G = _G };
_G.setmetatable(_ENV, { __index = function(_, k)
    return _G.rawget(_G, k);
end });

local Stack = {};











return Stack;