require 'setup';

function Server_StartGame(game, standing)
	isAutoDist = game.ServerGame.Settings.AutomaticTerritoryDistribution;

	if isAutoDist then
		setup(game);
	end

	makeHostOnlyHaveOneTerritory(game, standing);
end

function makeHostOnlyHaveOneTerritory(game, standing)
	-- the host's territories can't be changed after distribution, so limit host to 1 territory

	local hasCustomScenario = not not game.ServerGame.Settings.CustomScenario;

	if hasCustomScenario and isAutoDist then
		-- host may have put their territories in a way to prevent fights between areas
		return;
	end

	local host = game.ServerGame.Settings.StartedBy;

	if not host then
		return;
	end

	local foundHostFirstTerr = false;

	for terrId, terr in pairs(standing.Territories) do
		if terr.OwnerPlayerID == host then
			if foundHostFirstTerr then
				if not hasCustomScenario then
					standing.Territories[terrId].NumArmies = WL.Armies.Create(game.ServerGame.Settings.InitialNeutralsInDistribution);
				end

				standing.Territories[terrId].OwnerPlayerID = WL.PlayerID.Neutral;
			else
				foundHostFirstTerr = true;
				standing.Territories[terrId].NumArmies = WL.Armies.Create(game.ServerGame.Settings.OneArmyMustStandGuardOneOrZero);
				standing.Territories[terrId].Structures = {};
			end
		end
	end
end
