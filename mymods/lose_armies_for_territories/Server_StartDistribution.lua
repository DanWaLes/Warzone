require "LoseArmiesForTerritories"

-- set initial Mod data (manual dist only) - called in manual dist only

function Server_StartDistribution(game, standing)
	SetInitialStorage(game);
end