require "LooseArmiesPerTerritory"

-- set initial Gold and Mod data (auto dist only) - called in manual and auto dist

function Server_StartGame(game, standing)
	if not game.Settings.AutomaticTerritoryDistribution then
		-- is manual dist - already done this task in Server_StartDistribution
		return;
	end

	SetInitialGold(game);
	SetInitialStorage(game);
end