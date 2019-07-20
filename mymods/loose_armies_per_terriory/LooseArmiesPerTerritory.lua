require "Util";

-- core functions for this mod

-- https://www.warzone.com/wiki/Mod_API_Reference:ServerGame
-- https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
-- https://www.warzone.com/wiki/Mod_API_Reference:TerritoryStanding

function GatherPlayerData(pID, game)
	-- @param pID as in the player's actual id
	-- can't modify income, so commerce has to be used - can modify gold

	local player = {};
	local playerId = PlayerIdIntToPlayerId(pID, game);
	local lastestTurnStanding = game.ServerGame.LatestTurnStanding or game.ServerGame.TurnZeroStanding;
	-- LatestTurnStanding is nil in Server_StatGame, the above line contains a bug though

	-- player effectively extends playerId however playerId isn't writable
	player.ID = pID;
	print(tprint(lastestTurnStanding));
	player.Gold = lastestTurnStanding.NumResources(pID, WL.ResourceType.Gold);
	player.IsAI = playerId.IsAI;
	player.State = playerId.State;
	player.NumTerritories = GetTerritoriesByPlayerID(pID, game).NumTerritories;
	player.CorrectedGold = player.Gold - player.NumTerritories;

	-- Gold can't be negative
	if player.CorrectedGold < 0 then
		player.CorrectedGold = 0;
	end

	print("GatherPlayerData player exiting with");
	print(tprint(player));
	return player;
end

function GatherAllPlayerData(game)
	local allPlayerData = {};
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		allPlayerData[i] = GatherPlayerData(playerId.ID, game);
	end

	return allPlayerData;
end

function SetInitialGold(game)
	local allPlayerData = GatherAllPlayerData(game);

	for i,player in pairs(allPlayerData) do
		game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.CorrectedGold);
	end
end

function SetInitialStorage(game)
	-- can only store data about human players
	local playerGameData = Mod.PlayerGameData;
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		if not playerId.IsAI then
			playerGameData[playerId.ID].HasReduceGold = false;
			Mod.PlayerGameData = playerGameData;
		end
	end
end