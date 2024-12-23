-- copied from https://github.com/DanWaLes/Warzone/tree/master/mods/libs/lua_util

function startsWith(str, sub)
	return string.sub(str, 1, string.len(sub)) == sub;
end

function split(str, separator)
	-- https://stackoverflow.com/questions/1426954/split-string-in-lua#answer-7615129

	if not separator then
		separator = '%s';
	end

	local t = {};

	for str in string.gmatch(str, '([^'.. separator ..']+)') do
		table.insert(t, str);
	end

	return t;
end