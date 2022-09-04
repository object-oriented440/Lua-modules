---
--- @author zsh in 2022/8/20 16:55
--- 遍历来自标准输入的所有单词的迭代器


local function allwords()
    local line = io.read();
    local pos = 1;

    return function()
        while (line) do
            local w, p = string.match(line, '(%w+)()', pos); -- TODO:了解一下空匹配

            if (w) then
                pos = p;
                return w;
            else
                line = io.read();
                pos = pos + 1;
            end
            return nil;
        end
    end
end

---改进版
local function advanced_allwords(f)
    if (type(f) == 'function') then
        for line in io.lines() do
            for word in string.gmatch(line, '%w+') do
                f(word);
            end
            if (string.match(line, '<EOF>')) then
                return ;
            end
        end
    end
end

---牛！
--advanced_allwords(print);

local count = 0;
advanced_allwords(function(...)
    local args = { ... };
    if (#args ~= 1) then
        print('param ~= 1');
    else
        local word = args[1];
        if (word == 'hello') then
            count = count + 1;
        end
    end
end)
print(count);
