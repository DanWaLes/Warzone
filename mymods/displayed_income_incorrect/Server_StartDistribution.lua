require "Util"

-- set initial Mod data (manual dist) - called in manual dist only

function Server_StartDistribution(game, standing)
	print("init Server_StartDistribution manualdist");
	
	Util_SetInitialStorage(game, "enteredServer_StartDist");
end