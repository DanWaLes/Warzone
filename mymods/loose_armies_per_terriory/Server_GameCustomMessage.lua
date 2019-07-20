require "Util"
require "LooseArmiesPerTerritory"

-- apply the changes in Gold

function Server_GameCustomMessage(game, playerId, payload)
	print("init Server_GameCustomMessage");
	print("Server_GameCustomMessage game = ");
	print(tprint(game));
	print("Server_GameCustomMessage playerId = ");
	print(playerId)
	print("Server_GameCustomMessage payload = ");
	print(tprint(payload));

	local player = GatherPlayerData(playerId, game);

	if player == nil then
		print("player in Server_GameCustomMessage from gatherPlayerData is nil");
		return;
	end

	print("Server_GameCustomMessage player = ");
	print(tprint(player));

	print("player.ID = " .. tostring(player.ID));
	print("WL.ResourceType.Gold = " .. tostring(WL.ResourceType.Gold));
	print("player.CorrectedGold = " .. tostring(player.CorrectedGold));

	game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.CorrectedGold);

	local playerGameData = Mod.PlayerGameData;

	playerGameData[playerId].HasReduceGold = true;
	Mod.PlayerGameData = playerGameData;
end