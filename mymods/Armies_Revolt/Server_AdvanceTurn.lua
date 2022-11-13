function Server_AdvanceTurn_End(game, addNewOrder)
	local swaps = decideRandomPlayerSwaps(game);

	doSwaps(game, addNewOrder, swaps);
end

function pickRandomPlayer(playerIds)
	local ret = {};
	local i = math.random(1, #playerIds);
	local randomPlayer = playerIds[i];
	table.remove(playerIds, i);

	ret.randomPlayer = randomPlayer;
	ret.playerIds = playerIds;
	return ret;
end

function pick2RandomPlayers(playerIds)
	local randomPlayers = {};

	local r1 = pickRandomPlayer(playerIds);
	playerIds = r1.playerIds;
	randomPlayers[1] = r1.randomPlayer;

	if (#playerIds > 0) then
		local r2 = pickRandomPlayer(playerIds);
		playerIds = r2.playerIds;
		randomPlayers[2] = r2.randomPlayer;
	end

	local ret = {};
	ret.randomPlayers = randomPlayers;
	ret.playerIds = playerIds;

	return ret;
end

function decideRandomPlayerSwaps(game)
	local players = game.ServerGame.Game.PlayingPlayers;
	local playerIds = {};

	for id, player in pairs(players) do
		table.insert(playerIds, id);
	end

	local swaps = {};

	while true do
		local ret = pick2RandomPlayers(playerIds);

		playerIds = ret.playerIds;

		if (#ret.randomPlayers > 1) then
			swaps[ret.randomPlayers[1]] = ret.randomPlayers[2];
			swaps[ret.randomPlayers[2]] = ret.randomPlayers[1];
		end

		if (#playerIds == 0) then
			break;
		end
	end

	return swaps;
end

function doSwaps(game, addNewOrder, swaps)
	local mods = {};

	for tId, territory in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if not territory.IsNeutral and territory.Structures == nil and #territory.NumArmies.SpecialUnits < 1 then
			local swap = doSwap(territory, swaps);
			if swap ~= nil then
				table.insert(mods, swap);
			end
		end
	end

	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, 'Armies revolt!', {}, mods));
end

function doSwap(territory, swaps)
	local swapWith = swaps[territory.OwnerPlayerID];

	if math.random() < (1 - Mod.Settings.RevoltChance / 100) then
		local mod = WL.TerritoryModification.Create(territory.ID);
		mod.SetOwnerOpt = swapWith;
		return mod;
	end
end
