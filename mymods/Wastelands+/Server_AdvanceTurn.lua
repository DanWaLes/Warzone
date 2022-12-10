require 'settings'
require 'util'

function Server_AdvanceTurn_End(game, addNewOrder)
	makeRuntimeWastelands(game, addNewOrder);
end

function makeRuntimeWastelands(game, addNewOrder)
	local publicGameData = Mod.PublicGameData;

	for terrId, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		local tIdIndex = publicGameData.data.wastelandedIndexes[terrId];
		local existingArmies = territory.NumArmies.NumArmies;

		if tIdIndex then
			if territory.IsNeutral then
				publicGameData.data.wastelandData[tIdIndex][1] = {existingArmies};
			else
				table.remove(publicGameData.data.wastelandData, tIdIndex);
				publicGameData.data.wastelandedIndexes[terrId] = nil;
			end
		else
			if territory.IsNeutral then
				local terr = {id = terrId};

				if Mod.Settings.TreatAllNeutralsAsWastelands then
					terr[1] = {existingArmies};
				end

				table.insert(publicGameData.data.wastelandData, terr);
			end
		end
	end

	local maxExtraWastelands = 4;
	local n = 1;

	while n < maxExtraWastelands do
		if Mod.Settings['EnabledW' .. n] then
			local numWastelands = Mod.Settings['W' .. n .. 'Num'];

			if Mod.Settings['W' .. n .. 'Type'] == 1 then
				numWastelands = 0;
			end

			while numWastelands > 0 do
				local size = Mod.Settings['W' .. n .. 'Size'];
				local rand = Mod.Settings['W' .. n .. 'Rand'];

				size = size + math.random(-rand, rand);
				if size < 0 then
					size = 0;
				elseif size > 100000 then
					size = 100000;
				end

				local i = math.random(1, #publicGameData.data.wastelandData);

				if not publicGameData.data.wastelandData[i][1] then
					publicGameData.data.wastelandData[i][1] = {};
				end

				table.insert(publicGameData.data.wastelandData[i][1], size);
				numWastelands = numWastelands - 1;
			end
		end

		n = n + 1;
	end

	local overlapMode = Mod.Settings.OverlapMode;

	publicGameData.data.wastelandedIndexes = {};
	local territoryMods = {};

	for i, terr in pairs(publicGameData.data.wastelandData) do
		if publicGameData.data.wastelandData[i][1] then
			if overlapMode == 1 then
				publicGameData.data.wastelandData[i][1] = terr[1][math.random(1, #terr[1])];
			elseif overlapMode == 2 then
				publicGameData.data.wastelandData[i][1] = terr[1][1];
			elseif overlapMode == 3 then
				publicGameData.data.wastelandData[i][1] = terr[1][#terr[1]];
			else
				table.sort(publicGameData.data.wastelandData[i][1], function(a, b)
					return a > b;
				end);

				if overlapMode == 4 then
					publicGameData.data.wastelandData[i][1] = terr[1][#terr[1]];
				else
					publicGameData.data.wastelandData[i][1] = terr[1][1];
				end
			end

			local territoryMod = WL.TerritoryModification.Create(terr.id);
			territoryMod.SetArmiesTo = terr[1];
			table.insert(territoryMods, territoryMod);

			publicGameData.data.wastelandedIndexes[terr.id] = i;
		else
			publicGameData.data.wastelandData[i] = nil;
		end
	end

	local publicGameData = Mod.PublicGameData;
	publicGameData.data = data;
	Mod.PublicGameData = publicGameData;

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Made runtime wastelands', {}, territoryMods));
end