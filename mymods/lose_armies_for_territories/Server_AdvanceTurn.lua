require "Util"
require "LoseArmiesPerTerritory"

function Server_AdvanceTurn_Start(game, addNewOrder)
	-- on turn advance, reduce each AI players income
	local serverplayers = game.ServerGame.Game.Players;

	for i,player in pairs(serverplayers) do
		if player.IsAIOrHumanTurnedIntoAI and PlayerIsPlaying(player) then
			-- human may not have come back and is possible to bypass the Gold changes if only using player.IsAI
			SetGold(player.ID, game, addNewOrder);
		end
	end
end

function Server_AdvanceTurn_End(game, addNewOrder)
	-- say that we're ready to reduce gold (for human players as Client_GameRefresh can be called multiple times per turn)
	local serverplayers = game.ServerGame.Game.Players;
	local playerGameData = Mod.PlayerGameData;

	for i,player in pairs(serverplayers) do
		if not player.IsAI and PlayerIsPlaying(player) then
			playerGameData[player.ID].HasReduceGold = false;
			Mod.PlayerGameData = playerGameData;
		end
	end
end
