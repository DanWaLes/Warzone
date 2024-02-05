-- https://www.warzone.com/Forum/707426-print-table-writing-mod

local function p(obj, p2)
	function tprint(tbl, indent)
		if type(tbl) ~= 'table' then
			return tostring(tbl);
		end

		if not indent then
			indent = 0;
		end

		-- arrays dont have a proxy type
		if numKeys(tbl) ~= #tbl and tbl.proxyType then
			return DumpProxy(tbl, indent + 2);
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
					toprint = toprint .. DumpProxy(v, indent + 2) .. ',\r\n';
				else
					toprint = toprint .. tprint(v, indent + 2) .. ',\r\n';
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

	function DumpProxy(obj, indent)
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
					str = str .. tprint(value, indent);
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

	if type(obj) == 'table' then
		return tprint(obj, p2);
	else
		return tostring(obj);
	end
end

function tblprint(tbl)
	print(p(tbl));
end

function round(n, dp)
	if not n then
		print('n is nil');
		return;
	end

	-- http://lua-users.org/wiki/SimpleRound
	local multi = 10 ^ (dp or 0);

	return math.floor((n * multi + 0.5)) / multi;
end

function numKeys(tbl)
	local n = 0;

	for k, v in pairs(tbl) do
		n = n + 1;
	end

	return n;
end

function startsWith(str, sub)
	return string.sub(str, 1, string.len(sub)) == sub;
end

function split(str, sepperator)
	-- https://stackoverflow.com/questions/1426954/split-string-in-lua#answer-7615129
	if not sepperator then
		sepperator = '%s';
	end

	local t = {};
	for str in string.gmatch(str, '([^'.. sepperator ..']+)') do
		table.insert(t, str);
	end
	return t;
end

function placeOrderInCorrectPosition(clientGame, newOrder)
	if not newOrder.OccursInPhase then
		local orders = clientGame.Orders;
		table.insert(orders, newOrder);
		clientGame.Orders = orders;
	else
		local orders = {};
		local addedNewOrder = false;

		for _, order in pairs(clientGame.Orders) do
			if order.OccursInPhase then
				if not addedNewOrder and order.OccursInPhase > newOrder.OccursInPhase then
					table.insert(orders, newOrder);
					addedNewOrder = true;;
				end

				table.insert(orders, order);
			else
				table.insert(orders, order);
			end
		end

		if not addedNewOrder then
			table.insert(orders, newOrder);
		end

		clientGame.Orders = orders;
	end
end

function teamIdToTeamName(teamId)
	-- teamId 0 becomes Team A
	-- teamId 3 becomes Team D
	-- teamId 25 becomes Team Z
	-- teamId 26 becomes Team AA
	-- teamId 27 becomes Team AB
	-- based on https://stackoverflow.com/questions/8240637/convert-numbers-to-letters-beyond-the-26-character-alphabet#answer-64456745

	local A = string.byte('A', 1);
	local lettersInAlphabet = 26;
	local teamName = '';

	while teamId >= 0 do
		local c = string.char(A + (teamId % lettersInAlphabet));

		teamName = c .. teamName;
		teamId = math.floor(teamId / lettersInAlphabet) - 1;
	end

	return 'Team ' .. teamName;
end

function teamNameToTeamId(teamName)
	-- print(teamIdToTeamName(52));
	-- print(teamNameToTeamId('Team BA')); -- this does not match up with the above

	if type(teamName) ~= 'string' then
		print('teamName in teamNameToTeamId must be a string');
		return;
	end

	local i, j = string.find(teamName, '^Team ');
	if i and j then
		teamName = string.sub(teamName, j + 1, #teamName);
	else
		print('teamName in teamNameToTeamId must start with "Team "');
		return;
	end

	teamName = string.upper(teamName);

	local A = string.byte('A', 1);
	local lettersInAlphabet = 26;
	local teamId = 0;

	i = 1;
	while i < (#teamName + 1) do
		local c = string.byte(teamName, i);
		teamId = teamId + (c - A) + (lettersInAlphabet * (i - 1));
		i = i + 1;
	end

	return teamId;
end

function profileLinkToPlayerId(str)
	-- print(profileLinkToPlayerId('https://www.warzone.com/Profile?p=9522268564&u=DanWL_1'));

	if type(str) ~= 'string' then
		print('str in profileLinkToPlayerId is not a string');
		return;
	end

	str = string.lower(str);
	str = string.gsub(str, '^https?:%/%/', '');
	str = string.gsub(str, '^www%.', '');

	local i, j = string.find(str, '^warzone%.com');
	local k, l = string.find(str, '^warlight%.net');
	if i and j then
		str = string.sub(str, j + 1, #str);
	elseif k and l then
		str = string.sub(str, l + 1, #str);
	else
		print('invalid profile link domain');
		return;
	end

	i, j = string.find(str, '^%/profile%?p=');
	if i and j then
		str = string.sub(str, j + 1, #str);
	else
		print('invalid profile link profile');
		return;
	end

	str = string.gsub(str, '&u=.+$', '');

	i, j = string.find(str, '^%d+$');
	if not (i and j) then
		print('invalid profile link digitsonly');
		return;
	end

	if #str < 8 then
		print('invalid player');
		return;
	end

	str = string.sub(str, 3, #str - 2);

	return tonumber(str);
end