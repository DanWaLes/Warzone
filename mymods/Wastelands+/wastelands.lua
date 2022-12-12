function generateWastelands(numNeutrals, neutrals, wastelands, notIncluding, wastelandData)
	if wastelandData then
		wastelands = generateWastelandGroup(numNeutrals, neutrals, wastelands, wastelandData[1], wastelandData[2], 0);
	end

	local maxExtraWastelands = 5;
	local n = 1;

	while n < maxExtraWastelands do
		if Mod.Settings['EnabledW' .. n] then
			local numWastelands = Mod.Settings['W' .. n .. 'Num'];

			if Mod.Settings['W' .. n .. 'Type'] == notIncluding then
				numWastelands = 0;
			end

			local size = Mod.Settings['W' .. n .. 'Size'];
			local rand = Mod.Settings['W' .. n .. 'Rand'];

			wastelands = generateWastelandGroup(numNeutrals, neutrals, wastelands, numWastelands, size, rand);
		end

		n = n + 1;
	end

	return wastelands;
end

function generateWastelandGroup(numNeutrals, neutrals, wastelands, numWastelands, size, rand)
	while numWastelands > 0 do
		size = size + math.random(-rand, rand);
		if size < 0 then
			size = 0;
		elseif size > 100000 then
			size = 100000;
		end

		local i = math.random(1, numNeutrals);
		local neutral = neutrals[i];

		if not wastelands[neutral.id] then
			wastelands[neutral.id] = {};
		end

		table.insert(wastelands[neutral.id], size);
		numWastelands = numWastelands - 1;
	end

	return wastelands;
end

function placeWastelands(wastelands, onWastelandSizeDecided)
	local overlapMode = Mod.Settings.OverlapMode;

	for terrId, tWastelandData in pairs(wastelands) do
		if overlapMode == 1 then
			wastelands[terrId] = {tWastelandData[math.random(1, #tWastelandData)]};
		elseif overlapMode == 2 then
			wastelands[terrId] = {tWastelandData[1]};
		elseif overlapMode == 3 then
			wastelands[terrId] = {tWastelandData[#tWastelandData]};
		else
			table.sort(tWastelandData, function(a, b)
				return a > b;
			end);

			if overlapMode == 4 then
				wastelands[terrId] = {tWastelandData[#tWastelandData]};
			else
				wastelands[terrId] = {tWastelandData[1]};
			end
		end

		onWastelandSizeDecided(terrId, wastelands[terrId][1]);
	end

	return wastelands;
end