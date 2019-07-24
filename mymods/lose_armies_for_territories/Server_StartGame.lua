require "LoseArmiesForTerritories"

-- set initial Mod data (auto and manual dist) - called in manual and auto dist
-- trying to do in maul dist using Server_StartDistrubtion causes standing.NumResources to be nil

function Server_StartGame(game, standing)
	print("init Server_StartGame");
	SetInitialStorage(game, standing);
end