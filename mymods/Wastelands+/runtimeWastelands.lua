require 'wastelands'

function makeRuntimeWastelands(game, addNewOrder)
	local publicGameData = Mod.PublicGameData;

	local numNeutrals = 0;
	local neutrals = {};
	local wastelands = {};

	for terrId, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if territory.IsNeutral then
			numNeutrals = numNeutrals + 1;
			neutrals[numNeutrals] = {id = terrId};

			if publicGameData.wastelands[terrId] or Mod.Settings.TreatAllNeutralsAsWastelands then
				wastelands[terrId] = {territory.NumArmies.NumArmies};				
			end
		end
	end

	wastelands = generateWastelands(numNeutrals, neutrals, wastelands, 1);

	local territoryMods = {};
	wastelands = placeWastelands(wastelands, function(terrId, size)
		if size ~= game.ServerGame.LatestTurnStanding.Territories[terrId].NumArmies.NumArmies then
			local territoryMod = WL.TerritoryModification.Create(terrId);
			territoryMod.SetArmiesTo = size;
			table.insert(territoryMods, territoryMod);
		end
	end);

	publicGameData.wastelands = wastelands;
	Mod.PublicGameData = publicGameData;

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Made runtime wastelands', {}, territoryMods));
end