---
--- @author zsh in 2022/9/3 23:41
--- �ַ���������

-- ��Ҫ���� for ѭ������ .. �����ַ������� table ���������ַ�����Ȼ�� table.concat һ��������
-- ע���ˣ�ʹ�� table.concat ��Ҫ�� .. ���� table.concat �Ľ���ˣ���Ϊ��ʱ�������������Ѿ��ܳ��ˡ�

local Load = require('chang.modules.utils.Load');

-- ������
local filename = 'chang/modules/utils/datastructure/StringBuffer.txt';

Load.xpcall(function()
    local f = assert(io.open(filename,'w'));
    f:write([=[
        1\n .. filename
        2
        3
        4
        5
    ]=]);
    f:close();

    local old_input = io.input();
    io.input(filename);
    local t = {};
    for line in io.lines() do
        t[#t + 1] = line;
    end
    io.input(old_input);
    local content = table.concat(t, '\n');
    print(content);
end)