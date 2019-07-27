require "Util"

-- force-enable commerce if needed and apply bonus overrider if needed

function Server_Created(game, settings)
	print("init Server_Created");

	local publicGameData = Mod.PublicGameData;-- can be read by client

	publicGameData.enteredServer_StartGame = false;
	publicGameData.enteredServer_StartDist = false;
	Mod.PublicGameData = publicGameData;
end