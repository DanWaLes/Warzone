require "Util";

-- core functions for this mod

-- https://www.warzone.com/wiki/Mod_API_Reference:ServerGame
-- https://www.warzone.com/wiki/Mod_API_Reference:GamePlayer
-- https://www.warzone.com/wiki/Mod_API_Reference:TerritoryStanding

function GatherPlayerData(pID, game, standing)
	-- @param pID as in the player's actual id
	-- can't modify income, so commerce has to be used - can modify gold

	local player = {};
	local playerId = PlayerIdIntToPlayerId(pID, game);
	if not standing then
		standing = game.ServerGame.LatestTurnStanding;
		-- LatestTurnStanding is nil in Server_StatGame, so pass standing as argument from there
		-- otherwise use the default LastestTurnStanding
	end

	-- player effectively extends playerId however playerId isn't writable
	player.ID = pID;
	player.Gold = standing.NumResources(pID, WL.ResourceType.Gold);
	player.IsAI = playerId.IsAI;
	player.State = playerId.State;
	player.NumTerritories = GetTerritoriesByPlayerID(pID, standing).NumTerritories;
	player.CorrectedGold = player.Gold - player.NumTerritories;

	-- Gold can't be negative
	if player.CorrectedGold < 0 then
		player.CorrectedGold = 0;
	end

	print("GatherPlayerData player exiting with");
	print(tprint(player));
	return player;
end

function GatherAllPlayerData(game, standing)
	local allPlayerData = {};
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		allPlayerData[i] = GatherPlayerData(playerId.ID, game, standing);
	end

	return allPlayerData;
end

function SetInitialGold(game, standing)
	print("init SetInitialGold");
	local allPlayerData = GatherAllPlayerData(game, standing);
	print("got allPlayerData, about to SetPlayerResource");
	print(tprint(WL.ResourceType));
	for i,player in pairs(allPlayerData) do
		print("on player " .. tostring(i));
		print("player\n" .. tprint(player));
		game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.CorrectedGold);
	end
	print("done SetPlayerResource");
	print("out it SetInitialGold");
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