require "Util"

-- apply the changes in Gold
function Server_GameCustomMessage(game, playerId, payload)
	print("init Server_GameCustomMessage");

	-- prevent infinite loop of sending messages
	local playerGameData = Mod.PlayerGameData;

	playerGameData[playerId].HasReduceGold = true;
	Mod.PlayerGameData = playerGameData;

	local player = Util_PlayerIdToPlayer(playerId, game);

	if player == nil then
		print("404 player not found");
		return;
	end

	if not Util_PlayerIsPlaying(player) then
		return;
	end

	game.ServerGame.SetPlayerResource(playerId, WL.ResourceType.Gold, Util_GetGold());-- throws a whoops error in manual dist - probably because game orders can't take place at this point

	if not playerGameData[playerId].HasShownIncorrectGoldWarning then
		local playerGameData = Mod.PlayerGameData;

		playerGameData[playerId].HasShownIncorrectGoldWarning = true;
		Mod.PlayerGameData = playerGameData;
	end
end