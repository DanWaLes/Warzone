require "LooseArmiesPerTerritory"

-- set initial Gold and Mod data (manual dist only) - called in manual dist only

function Server_StartDistribution(game, standing)
	SetInitialGold(game);
	SetInitialStorage(game);
end