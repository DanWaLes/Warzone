require "Util"
require "LoseArmiesForTerritories"

-- apply the changes in Gold
function Server_GameCustomMessage(game, playerId, payload, setReturn)
	local player = GatherPlayerData(playerId, game);

	if player == nil then
		print("player in Server_GameCustomMessage from gatherPlayerData is nil");
		return;
	end

	-- prevent infinite loop of sending messages
	local playerGameData = Mod.PlayerGameData;

	playerGameData[playerId].HasReduceGold = true;
	Mod.PlayerGameData = playerGameData;

	if not PlayerIsPlaying(player) then
		return;
	end

	game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.CorrectedGold);

	if not playerGameData[playerId].HasShownIncorrectGoldWarning then
		local playerGameData = Mod.PlayerGameData;

		playerGameData[playerId].HasShownIncorrectGoldWarning = true;
		Mod.PlayerGameData = playerGameData;
	end

	debugPrint("player =\n" .. tprint(player));

	setReturn(player);
end