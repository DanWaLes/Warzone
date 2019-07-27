-- https://stackoverflow.com/questions/41942289/display-contents-of-tables-in-lua#answer-41943392
function Util_tprint (tbl, indent)
	if tbl == nil then
		return "tbl is nil";
	end
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
 
  return toprint;
end

function Util_PlayerIsPlaying(player)
	return player.State == WL.GamePlayerState.Playing;
end

function Util_IsAutoDist(game)
	-- game ServerGame or ClientGame
	return game.Settings.AutomaticTerritoryDistribution;
end

function Util_IsManualDist(game)
	-- game ServerGame or ClientGame
	return not Util_IsAutoDist(game);
end

function Util_GetGold()
	return 1; -- for argument's sake
end

function Util_PlayerIdToPlayer(playerId, game)
	-- playerId int
	-- game ServerGame

	local ret = nil;
	local serverplayers = game.ServerGame.Game.Players;

	for i,player in pairs(serverplayers) do
		if player.ID == playerId then
			ret = player;
			break;
		end
	end

	return ret;
end

function Util_SetInitialStorage(game, publicGameDataKey)
	-- can only store data about human players
	local playerGameData = Mod.PlayerGameData;
	local serverplayers = game.ServerGame.Game.Players;

	for i,player in pairs(serverplayers) do
		if not player.IsAI then
			playerGameData[player.ID] = {};
			playerGameData[player.ID].HasReduceGold = false;
			playerGameData[player.ID].HasShownIncorrectGoldWarning = false;
			Mod.PlayerGameData = playerGameData;
		end
	end

	local publicGameData = Mod.PublicGameData;

	publicGameData[publicGameDataKey] = true;
	Mod.PublicGameData = publicGameData;
end