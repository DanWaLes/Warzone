require 'wastelands'

function makeDistributionWastelands(game, standing)
	local numPlayers = 0;
	for _, player in pairs(game.ServerGame.Game.Players) do
		numPlayers = numPlayers + 1;
	end

	local minTerritoriesNeeded = numPlayers;

	if Mod.Settings.UseMaxTerrs and game.Settings.LimitDistributionTerritories > 0 then
		minTerritoriesNeeded = minTerritoriesNeeded * game.Settings.LimitDistributionTerritories;
	end

	local numNeutrals = 0;
	local neutrals = {};
	local available = {neutrals = {}, length = 0};
	local availableIndexes = {};
	local wastelands = {};
	local wastelandIndexes = {};
	local normalWastelandCount = 0;
	local numNormalWastelands = game.Settings.NumberOfWastelands;
	local numTerritories = 0;

	for terrId, territory in pairs(standing.Territories) do
		if territory.IsNeutral or (not game.Settings.AutomaticTerritoryDistribution and territory.OwnerPlayerID == WL.PlayerID.AvailableForDistribution) then
			numNeutrals = numNeutrals + 1;

			local existingArmies = territory.NumArmies.NumArmies;

			if numNormalWastelands > 0 and normalWastelandCount < numNormalWastelands and game.Settings.WastelandSize == existingArmies then
				normalWastelandCount = normalWastelandCount + 1;

				wastelands[terrId] = {existingArmies};
				wastelandIndexes[normalWastelandCount] = terrId;
			else
				available.length = available.length + 1;
				available.neutrals[available.length] = terrId;
				availableIndexes[terrId] = available.length;
			end

			neutrals[numNeutrals] = {id = terrId};
		end

		numTerritories = numTerritories + 1;
	end

	local numWastelandsToRemove = -(numTerritories - minTerritoriesNeeded - normalWastelandCount);

	while numWastelandsToRemove > 0 do
		local toRemove = wastelandIndexes[numWastelandsToRemove];
		table.remove(wastelandIndexes, numWastelandsToRemove);
		wastelands[toRemove] = nil;
		standing.Territories[toRemove].OwnerPlayerID = WL.PlayerID.AvailableForDistribution;

		numWastelandsToRemove = numWastelandsToRemove - 1;
	end

	local i = numNeutrals;

	while numNeutrals > (numTerritories - minTerritoriesNeeded) do
		if not wastelandIndexes[i] then
			local toRemove = availableIndexes[neutrals[i].id];

			if toRemove then
				table.remove(available.neutrals, toRemove);
				available.length = available.length - 1;
			end

			table.remove(neutrals, i);
			numNeutrals = numNeutrals - 1;
		end

		i = i - 1;
	end

	local wastelandData;
	if Mod.Settings.CreateDistributionWastelandsAfterPicks and not game.Settings.AutomaticTerritoryDistribution then
		wastelandData = {game.Settings.NumberOfWastelands, game.Settings.WastelandSize};
	end

	wastelands = generateWastelands(numNeutrals, neutrals, available, wastelands, 2, wastelandData);

	placeWastelands(wastelands, function(terrId, size)
		standing.Territories[terrId].OwnerPlayerID = WL.PlayerID.Neutral;
		standing.Territories[terrId].NumArmies = WL.Armies.Create(size);
	end);

	local publicGameData = Mod.PublicGameData;
	publicGameData.wastelands = wastelands;
	Mod.PublicGameData = publicGameData;
end