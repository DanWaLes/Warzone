-- if there is a custom scenario remove it and match with the overwritten settings

function Server_StartGame(game, standing)
	if not game.Settings.CustomScenario then
		return;
	end

	print('is custom scenario')

	local numPlayerOwned = {};

	for id, terr in pairs(standing.Territories) do
		standing.Territories[id].NumArmies = WL.Armies.Create(0);

		if not terr.IsNeutral then
			if numPlayerOwned[terr.OwnerPlayerID] then
				standing.Territories[id].OwnerPlayerID = WL.PlayerID.Neutral;
			else
				numPlayerOwned[terr.OwnerPlayerID] = true;
			end
		end
	end

	print('removed custom scenario');
end