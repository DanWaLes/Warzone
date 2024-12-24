function round(n, dp)
	if type(n) ~= 'number' then
		print('n in round(n, dp) is not a number; is ' .. tostring(n));
		return;
	end

	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end

function tblLen(tbl)
	if type(tbl) ~= 'table' then
		print('tbl in tblLen(tbl) must be a table');
		return;
	end

	local n = 0;

	for k, v in pairs(tbl) do
		n = n + 1;
	end

	return n;
end

function map(array, func)
	local new_array = {};
	local i = 1;

	for _, v in pairs(array) do
		new_array[i] = func(v);
		i = i + 1;
	end

	return new_array;
end

function filter(array, func)
	local new_array = {};
	local i = 1;

	for _, v in pairs(array) do
		if func(v) then
			new_array[i] = v;
			i = i + 1;
		end
	end

	return new_array;
end

function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i);
		tbl[i], tbl[j] = tbl[j], tbl[i];
	end
end

function startsWith(str, sub)
	return string.sub(str, 1, string.len(sub)) == sub;
end

function split(str, pat)
	local t = {};  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat;
	local last_end = 1;
	local s, e, cap = str:find(fpat, 1);

	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t, cap);
		end

		last_end = e + 1;
		s, e, cap = str:find(fpat, last_end);
	end

	if last_end <= #str then
		cap = str:sub(last_end);
		table.insert(t, cap);
	end

	return t;
end

local function DumpTable(tbl)
	for k,v in pairs(tbl) do
		print('k = ' .. tostring(k) .. ' (' .. type(k) .. ') ' .. ' v = ' .. tostring(v) .. ' (' .. type(v) .. ')');
	end
end

local function DumpProxy(obj)
	print('type=' .. obj.proxyType .. ' readOnly=' .. tostring(obj.readonly) .. ' readableKeys=' .. table.concat(obj.readableKeys, ',') .. ' writableKeys=' .. table.concat(obj.writableKeys, ','));
end

function Dump(obj)
	if type(obj) == 'table' then
		if obj.proxyType ~= nil then
			DumpProxy(obj);
		else
			DumpTable(obj);
		end
	else
		print('Dump ' .. type(obj));
	end
end

local function tblprint_DumpProxy(obj, indent)
	if type(obj) ~= 'table' then
		return tostring(obj);
	end

	local str = '{';

	for _, key in pairs(obj.readableKeys) do
		if key ~= 'readableKeys' then
			str = str .. '\r\n' .. string.rep(' ', indent);
			if type(key) == 'string' then
				str = str .. key;
			else
				str = str .. '[' .. key .. ']';
			end

			str = str .. ' = ';

			local value = obj[key];

			if type(value) == 'table' then
				str = str .. tblprint_tprint(value, indent);
			elseif type(value) == 'string' then
				str = str .. '"' .. value .. '"';
			else
				str = str .. tostring(value);
			end

			str = str .. ',';
		end
	end

	return str .. '\r\n' .. string.rep(' ', indent - 2) .. '}';
end

local function tblprint_tprint(tbl, indent)
	if type(tbl) ~= 'table' then
		return tostring(tbl);
	end

	if not indent then
		indent = 0;
	end

	-- arrays dont have a proxy type
	if tblLen(tbl) ~= #tbl and tbl.proxyType then
		return tblprint_DumpProxy(tbl, indent + 2);
	end

	local toprint = '{\r\n';
	indent = indent + 2;

	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(' ', indent)

		if type(k) == 'number' then
			toprint = toprint .. '[' .. k .. '] = ';
		elseif type(k) == 'string' then
			toprint = toprint  .. k ..  ' = ';
		end

		if type(v) == 'table' then
			if v.__proxyID then
				toprint = toprint .. tblprint_DumpProxy(v, indent + 2) .. ',\r\n';
			else
				toprint = toprint .. tblprint_tprint(v, indent + 2) .. ',\r\n';
			end
		elseif type(v) == 'string' then
			toprint = toprint .. '"' .. v .. '",\r\n';
		else
			toprint = toprint .. tostring(v) .. ',\r\n';
		end
	end

	toprint = toprint .. string.rep(' ', indent - 2) .. '}';

	return toprint;
end

function tblprint(tbl)
	print(tblprint_tprint(tbl));
end

function numberToLetters(number)
	if type(number) ~= 'number' then
		print('number in numberToLetters(number) must be a number');
		return;
	end

	-- 0 becomes A
	-- 3 becomes D
	-- 25 becomes Z
	-- 26 becomes AA
	-- 27 becomes AB
	-- based on https://stackoverflow.com/questions/8240637/convert-numbers-to-letters-beyond-the-26-character-alphabet#answer-64456745

	local A = string.byte('A', 1);
	local lettersInAlphabet = 26;
	local letters = '';

	while number >= 0 do
		local c = string.char(A + (number % lettersInAlphabet));

		letters = c .. letters;
		number = math.floor(number / lettersInAlphabet) - 1;
	end

	return letters;
end

function lettersToNumber(letters)
	if type(letters) ~= 'string' then
		print('letters in lettersToNumber(letters) must be a string');
		return;
	end

	local A = string.byte('A', 1);
	local lettersInAlphabet = 26;
	local number = 0;

	for i = 1, #letters do
		local charValue = string.byte(letters, i) - A + 1;
		number = number * lettersInAlphabet + charValue;
	end

	return number - 1;
end
