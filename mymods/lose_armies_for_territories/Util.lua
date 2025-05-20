-- https://stackoverflow.com/questions/41942289/display-contents-of-tables-in-lua#answer-41943392
function tprint (tbl, indent)
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

function debugPrint(msg)
	-- for conditionally printing data that would help in debugging
	local debugEnabled = true;

	if debugEnabled then
		print(msg);
	end
end

-- http://lua-users.org/wiki/SimpleRound
-- there isn't a built -in math.round
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- ? isn't included in lua
function ternary(condition, iftrue, iffalse)
	if condition then
		return iftrue;
	else
		return iffalse;
	end
end

function GetTerritoriesByPlayerID(playerID, gameStanding)
	local ret = {};
	local serverterritories = gameStanding.Territories;

	ret.NumTerritories = 0;
	ret.Territories = {};

	for i,territory in pairs(serverterritories) do
		if territory.OwnerPlayerID == playerID then
			ret.Territories[i] = territory;
			ret.NumTerritories = ret.NumTerritories + 1;
		end
	end

	return ret;
end

function PlayerIdIntToPlayerId(playerIDInt, game)
	local ret;
	local serverplayers = game.ServerGame.Game.Players;

	for i,playerId in pairs(serverplayers) do
		if playerId.ID == playerIDInt then
			ret = playerId;
			break;
		end
	end

	return ret;
end

function PlayerIsPlaying(player)
	return player.State == WL.GamePlayerState.Playing;
end