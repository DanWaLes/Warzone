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
	local overlapMode = Mod.Settings.OverlapMode;

	while numWastelands > 0 do
		size = size + math.random(-rand, rand);
		if size < 0 then
			size = 0;
		elseif size > 100000 then
			size = 100000;
		end

		local i = math.random(1, numNeutrals);
		local neutral = neutrals[i];

		if wastelands[neutral.id] then
			local w = wastelands[neutral.id][1];
			if overlapMode == 1 then
				local j = math.random(1, 2);
				if j == 1 then
					size = wastelands[neutral.id][1];
				end
			elseif overlapMode == 4 then
				size = math.min(w, size);
			elseif overlapMode == 5 then
				size = math.max(w, size);
			end

			if overlapMode ~= 2 then
				wastelands[neutral.id][1] = size;
			end
		else
			wastelands[neutral.id] = {size};
		end

		numWastelands = numWastelands - 1;
	end

	return wastelands;
end

function placeWastelands(wastelands, placeWasteland)
	for terrId, tWastelandData in pairs(wastelands) do
		placeWasteland(terrId, tWastelandData[1]);
	end
end