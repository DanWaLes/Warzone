require '_util';

function messagifyArmies(armies)
	-- for including them in order
	if not armies then
		return '0 armies';
	end

	local str = armies.NumArmies .. ' armies';

	if not armies.SpecialUnits then
		return str;
	end

	local unitTypes = nil;

	for _, unit in pairs(armies.SpecialUnits) do
		if not unitTypes then
			unitTypes = {}
		end

		if unit.proxyType == 'CustomSpecialUnit' then
			if not unitTypes[unit.proxyType] then
				unitTypes[unit.proxyType] = {};
			end

			if not unitTypes[unit.proxyType][unit.Name] then
				unitTypes[unit.proxyType][unit.Name] = 0;
			end

			unitTypes[unit.proxyType][unit.Name] = unitTypes[unit.proxyType][unit.Name] + 1;
		else
			if not unitTypes[unit.proxyType] then
				unitTypes[unit.proxyType] = 0;
			end

			unitTypes[unit.proxyType] = unitTypes[unit.proxyType] + 1;
		end
	end

	if not unitTypes then
		return str;
	end

	str = str .. ' plus ';

	for proxyType, data in pairs(unitTypes) do
		if proxyType == 'CustomSpecialUnit' then
			for name, n in pairs(data) do
				if n == 1 then
					str = str .. 'a ' .. name;
				else
					str = str .. n .. ' ' .. name .. 's';
				end
			end
		else
			if data == 1 then
				str = str .. 'a ' .. proxyType;
			else
				str = str .. data .. ' ' .. proxyType .. 's';
			end
		end

		str = str .. ' ,';
	end

	return string.gsub(str, ' ,$', '');
end

local SEPARATOR = ',';

function stringifyArmies(armies)
	-- for including them in order payloads
	if not armies then
		return '';
	end

	local str = tostring(armies.NumArmies);

	if not armies.SpecialUnits then
		return str;
	end

	for _, unit in pairs(armies.SpecialUnits) do
		str = str .. SEPARATOR .. unit.ID;
	end

	return str;
end

function parseArmies(str)
	-- print('init parseArmies');

	-- for reading them in order payloads
	local ret = {
		NumArmies = 0,
		SpecialUnits = {}
	};

	local splt = split(str, SEPARATOR);
	local i = 1;

	while i < (#splt + 1) do
		local item = splt[i];

		if i == 1 then
			ret.NumArmies = tonumber(item);
		else
			table.insert(ret.SpecialUnits, item);
		end

		i = i + 1;
	end

	-- print('outit parseArmies');
	return ret;
end