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
	player.LoseArmiesPerXTerritoriesCost = round((player.NumTerritories / Mod.Settings.Territories) * Mod.Settings.Gold);
	player.CorrectedGold = player.Gold - player.LoseArmiesPerXTerritoriesCost;

	-- Gold can't be negative
	if player.CorrectedGold < 0 then
		player.CorrectedGold = 0;
		player.LoseArmiesPerXTerritoriesCost = player.Gold;
	end

	-- print("GatherPlayerData player exiting with");
	-- print(tprint(player));
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

function SetInitialStorage(game)
	-- print("init SetInitalStorage");
	-- can only store data about human players
	local playerGameData = Mod.PlayerGameData;
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		if not playerId.IsAI then
			playerGameData[playerId.ID] = {};
			playerGameData[playerId.ID].HasReduceGold = false;
			playerGameData[playerId.ID].HasShownIncorrectGoldWarning = false;
			Mod.PlayerGameData = playerGameData;
		end
	end

	-- print("Mod.PlayerGameData =\n" .. tprint(Mod.PlayerGameData));
	-- print("Set initial storage");
	-- https://www.warzone.com/wiki/Mod_Game_Data_Storage
end

function SetGold(playerID, game, addNewOrder)
	-- playerID as in the actual player id, not the player object

	-- game.ServerGame.SetPlayerResource(player.ID, WL.ResourceType.Gold, player.Gold);
	-- can't do the above as SetPlayerResource cannot be called from an AdvanceTurn hook.  To set resources from these hooks, add a GameOrderEvent instead.
	-- using game order event doesn't work properly - gold is modified here then gold is added, even when called from Server_AdvanceTurn_End (has to be called at Server_AdvanceTurn_Start to prevent this - results in lots of orders being skipped), so humans have to have Client_GameRefresh + Server_GameCustomMessage using SetPlayerResource and AIs have Server_AdvanceTurn_Start but even then the number of territories each player owned is likely to have changed from when the turn started and when the turn ended
	local player = GatherPlayerData(playerID, game);

	-- make the order
	local message = "Removed " .. tostring(Mod.Settings.Gold) .. " Gold for each " .. ternary(Mod.Settings.Territories == 1, "territory", tostring(Mod.Settings.Territories) .. "territories") .. " owned";
	local visibleToOpt = {playerID};
	local terrModsOpt = nil;
	local resources = {};
	resources[WL.ResourceType.Gold] = player.CorrectedGold;

	local setResources = {};

	setResources[playerID] = resources;

	addNewOrder(WL.GameOrderEvent.Create(playerID, message, visibleToOpt, terrModsOpt, setResources));
end

function GetDefaults(key)
	local defaults = {};

	defaults.Gold = 1;
	defaults.Territories = 1;
	defaults.GoldMinVal = -15;-- positive gold per turn
	defaults.GoldMaxVal = 15;-- negative gold per turn
	defaults.TerritoriesMinVal = 1;
	defaults.TerritoriesMaxVal = 15;
	defaults.EnableBonusOverrider = true;

	if key then
		return defaults[key];
	end

	return defaults;
end