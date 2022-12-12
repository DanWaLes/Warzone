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
			end

			neutrals[numNeutrals] = {id = terrId};
		end

		numTerritories = numTerritories + 1;
	end

	while numNeutrals > (numTerritories - minTerritoriesNeeded) do
		if (not wastelandIndexes[numNeutrals]) then
			table.remove(neutrals, numNeutrals);
		end

		numNeutrals = numNeutrals - 1;
	end

	local wastelandData;
	if Mod.Settings.CreateDistributionWastelandsAfterPicks and not game.Settings.AutomaticTerritoryDistribution then
		wastelandData = {game.Settings.NumberOfWastelands, game.Settings.WastelandSize};
	end

	wastelands = generateWastelands(numNeutrals, neutrals, wastelands, 2, wastelandData);

	placeWastelands(wastelands, function(terrId, size)
		standing.Territories[terrId].OwnerPlayerID = WL.PlayerID.Neutral;
		standing.Territories[terrId].NumArmies = WL.Armies.Create(size);
	end);

	local publicGameData = Mod.PublicGameData;
	publicGameData.wastelands = wastelands;
	Mod.PublicGameData = publicGameData;
end