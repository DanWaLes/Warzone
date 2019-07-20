require "Util"
require "LooseArmiesPerTerritory"

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- on turn advance, reduce each AI players income
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		if playerId.IsAI then
			local pID = playerId.ID;
			local aiPlayer = GatherPlayerData(pID, game);

			-- game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.Gold);
			-- can't do the above as SetPlayerResource cannot be called from an AdvanceTurn hook.  To set resources from these hooks, add a GameOrderEvent instead.

			local message = "Removed 1 Gold per territory";
			local visibleToOpt = {pID};
			local terrModsOpt = nil;
			local resources = {};
			resources[WL.ResourceType.Gold] = aiPlayer.Gold;

			local setResources = {};

			setResources[pID] = resources;

			addNewOrder(WL.GameOrderEvent.Create(pID, message, visibleToOpt, terrModsOpt, setResources));
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	-- say that we're ready to reduce gold (for human players as Client_GameRefresh can be called multiple times per turn)
	local serverplayers = game.ServerGame.Game.Players;
	local playerGameData = Mod.PlayerGameData;

	for i,player in pairs(serverplayers) do
		if not player.IsAI then
			playerGameData[player.ID].HasReduceGold = false;
			Mod.PlayerGameData = playerGameData;
		end
	end
end