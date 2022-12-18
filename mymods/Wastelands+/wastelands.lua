require 'util'

function generateWastelands(numNeutrals, neutrals, available, wastelands, notIncluding, wastelandData)
	if wastelandData then
		local ret = generateWastelandGroup(numNeutrals, neutrals, available, wastelands, wastelandData[1], wastelandData[2], 0);

		wastelands = ret.wastelands;
		available = ret.available;
	end

	local numWastelandGroups = (Mod.Settings.extraWasteland or 5) + 1;-- 5+1 is for backwards compatibility
	local n = 1

	while n < numWastelandGroups do
		if Mod.Settings['EnabledW' .. n] then
			local numWastelands = Mod.Settings['W' .. n .. 'Num'];

			if Mod.Settings['W' .. n .. 'Type'] == notIncluding then
				numWastelands = 0;
			end

			local size = Mod.Settings['W' .. n .. 'Size'];
			local rand = Mod.Settings['W' .. n .. 'Rand'];
			local ret = generateWastelandGroup(numNeutrals, neutrals, available, wastelands, numWastelands, size, rand);

			wastelands = ret.wastelands;
			available = ret.available;
		end

		n = n + 1;
	end

	return wastelands;
end

function generateWastelandGroup(numNeutrals, neutrals, available, wastelands, numWastelands, size, rand)
	local overlapMode = Mod.Settings.OverlapMode;

	while numWastelands > 0 do
		size = size + math.random(-rand, rand);
		if size < 0 then
			size = 0;
		elseif size > 100000 then
			size = 100000;
		end

		if available.length == 0 then
			available.length = numNeutrals;
			available.neutrals = clone(neutrals);
		end

		local i = math.random(1, available.length);
		local neutral = available.neutrals[i];

		if type(neutral) ~= 'table' then
			-- fixes a bug that was introduced in https://github.com/DanWaLes/Warzone/commit/d0574014dbcd98bd934f0b5e20d4b905d9cf78aa#diff-e21c5e081036d4af35859ff1b46bb37dc00df958e53b059a70538223a6122b90
			-- bug was prevented in https://github.com/DanWaLes/Warzone/commit/93e567f9e1bdfb13f8ef95e7901ce9538acc5597#diff-e21c5e081036d4af35859ff1b46bb37dc00df958e53b059a70538223a6122b90
			available.neutrals[i] = {id = neutral};
			neutral = available.neutrals[i];
		end

		if wastelands[neutral.id] then
			local w = wastelands[neutral.id][1];

			if overlapMode == 1 then
				if math.random(1, 2) == 1 then
					size = w;
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

		available.length = available.length - 1;
		table.remove(available.neutrals, i);

		numWastelands = numWastelands - 1;
	end

	return {wastelands = wastelands, available = available};
end

function placeWastelands(wastelands, placeWasteland)
	for terrId, tWastelandData in pairs(wastelands) do
		placeWasteland(terrId, tWastelandData[1]);
	end
end