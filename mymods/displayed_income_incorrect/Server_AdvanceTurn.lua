require "Util"

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- on turn advance, reduce each AI players income
	local serverplayers = game.ServerGame.Game.Players;

	for i,player in pairs(serverplayers) do
		if player.IsAIOrHumanTurnedIntoAI and Util_PlayerIsPlaying(player) then
			-- human may not have come back and is possible to bypass the Gold changes if only using player.IsAI
			SetGold(player, game, addNewOrder);
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	-- say that we're ready to reduce gold (for human players as Client_GameRefresh can be called multiple times per turn)
	local serverplayers = game.ServerGame.Game.Players;
	local playerGameData = Mod.PlayerGameData;

	for i,player in pairs(serverplayers) do
		if not player.IsAI and Util_PlayerIsPlaying(player) then
			playerGameData[player.ID].HasReduceGold = false;
			Mod.PlayerGameData = playerGameData;
		end
	end
end

function SetGold(player, game, addNewOrder)
	-- for ai players only
	local message = "Set gold to " .. Util_GetGold();
	local visibleToOpt = {player.ID};
	local terrModsOpt = nil;
	local resources = {};
	resources[WL.ResourceType.Gold] = player.CorrectedGold;

	local setResources = {};

	setResources[player.ID] = resources;

	addNewOrder(WL.GameOrderEvent.Create(player.ID, message, visibleToOpt, terrModsOpt, setResources));
end