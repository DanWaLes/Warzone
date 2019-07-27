require "Util"

-- set initial Mod data (auto dist) - called in manual turn 1 and auto dist

function Server_StartGame(game, standing)

	if Util_IsManualDist(game) then
		return;
	end

	print("init Server_StartGame autodist");
	
	Util_SetInitialStorage(game, "enteredServer_StartGame");
end