require 'settings';
require 'util';

function getNeutrals(game, standing)
	local numPlayers = 0;
	for _, player in pairs(game.ServerGame.Game.Players) do
		numPlayers = numPlayers + 1;
	end

	local minTerritoriesNeeded = numPlayers;

	if Mod.Settings.UseMaxTerrs and game.Settings.LimitDistributionTerritories > 0 then
		minTerritoriesNeeded = minTerritoriesNeeded * game.Settings.LimitDistributionTerritories;
	end

	local neutrals = {};
	local numNeutrals = 0;
	local numTerritories = 0;
	local normalWastelandCount = 0;-- so that neutrals of same size as wastelands arent counted
	local numNormalWastelands = game.Settings.NumberOfWastelands;

	for terrId, territory in pairs(standing.Territories) do
		if territory.IsNeutral or (not game.Settings.AutomaticTerritoryDistribution and territory.OwnerPlayerID == WL.PlayerID.AvailableForDistribution) then
			numNeutrals = numNeutrals + 1;

			local terr = {id = terrId};
			local existingArmies = territory.NumArmies.NumArmies;

			if numNormalWastelands > 0 and normalWastelandCount < numNormalWastelands and game.Settings.WastelandSize == existingArmies then
				terr[1] = {existingArmies};
				normalWastelandCount = normalWastelandCount + 1;
			end

			table.insert(neutrals, terr);
		end

		numTerritories = numTerritories + 1;
	end

	while true do
		if numNeutrals > (numTerritories - minTerritoriesNeeded) then
			table.remove(neutrals, numNeutrals);
			numNeutrals = numNeutrals - 1;
		else
			break;
		end
	end

	return {wastelandData = neutrals, numNeutrals = numNeutrals};
end

function makeDistributionWastelands(game, standing)
	if game.Settings.CustomScenario then
		return;
	end

	local data = getNeutrals(game, standing);
	local maxExtraWastelands = 4;
	local n = 1;

	while n < maxExtraWastelands do
		if Mod.Settings['EnabledW' .. n] then
			local numWastelands = Mod.Settings['W' .. n .. 'Num'];

			if Mod.Settings['W' .. n .. 'Type'] == 2 then
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

				local i = math.random(1, data.numNeutrals);

				if not data.wastelandData[i][1] then
					data.wastelandData[i][1] = {};
				end

				table.insert(data.wastelandData[i][1], size);
				numWastelands = numWastelands - 1;
			end
		end

		n = n + 1;
	end

	local overlapMode = Mod.Settings.OverlapMode;

	data.wastelandedIndexes = {};

	for i, _ in pairs(data.wastelandData) do
		if data.wastelandData[i][1] then
			if overlapMode == 1 then
				data.wastelandData[i][1] = data.wastelandData[i][1][math.random(1, #data.wastelandData[i][1])];
			elseif overlapMode == 2 then
				data.wastelandData[i][1] = data.wastelandData[i][1][1];
			elseif overlapMode == 3 then
				data.wastelandData[i][1] = data.wastelandData[i][1][#data.wastelandData[i][1]];
			else
				table.sort(data.wastelandData[i][1], function(a, b)
					return a > b;
				end);

				if overlapMode == 4 then
					data.wastelandData[i][1] = data.wastelandData[i][1][#data.wastelandData[i][1]];
				else
					data.wastelandData[i][1] = data.wastelandData[i][1][1];
				end
			end

			local terr = data.wastelandData[i];
			standing.Territories[terr.id].OwnerPlayerID = WL.PlayerID.Neutral;
			standing.Territories[terr.id].NumArmies = WL.Armies.Create(terr[1]);

			data.wastelandedIndexes[terr.id] = i;
		else
			data.wastelandData[i] = nil;
		end
	end

	local publicGameData = Mod.PublicGameData;
	publicGameData.data = data;
	Mod.PublicGameData = publicGameData;
end