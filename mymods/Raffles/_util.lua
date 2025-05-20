--[[
modified from
https://stackoverflow.com/questions/41942289/display-contents-of-tables-in-lua#answer-41943392
https://www.warzone.com/wiki/Mod_API_Reference#Proxy_Objects
]]

local function tprint(tbl, indent)
	if tbl == nil then
		return "tbl is nil";
	end
	if not indent then indent = 0 end

	local toprint = '{\r\n'
	indent = indent + 2

	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(' ', indent)

		if type(k) == 'number' then
			toprint = toprint .. '[' .. k .. '] = ';
		elseif type(k) == 'string' then
			toprint = toprint  .. k ..  ' = ';
		end

		if (type(v) == 'number') then
			toprint = toprint .. v .. ',\r\n';
		elseif (type(v) == "string") then
			toprint = toprint .. '"' .. v .. '",\r\n';
		elseif (type(v) == 'table') then
			local toPrint = v;

			if v.proxyType then
				local proxyTbl = {};

				for _, value in pairs(v.readableKeys) do
					if value ~= 'readableKeys' then
						proxyTbl[value] = v[value];
					end
				end

				toPrint = proxyTbl;
			end

			toprint = toprint .. tprint(toPrint, indent + 2) .. ',\r\n';
		else
			toprint = toprint .. '"' .. tostring(v) .. '",\r\n';
		end
	end

	toprint = toprint .. string.rep(' ', indent - 2) .. '}';

	return toprint;
end

function tblprint(tbl)
	print(tprint(tbl));
end

function round(n, dp)
	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end