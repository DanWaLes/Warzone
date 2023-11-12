require '_util';

function print2(addNewOrder, msg)
	addNewOrder(WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg));
end

function Server_AdvanceTurn_Start(game, addNewOrder)
	print2(addNewOrder, 'game.Settings.AutoBootTime = ' .. game.Settings.AutoBootTime);
	print2(addNewOrder, 'game.Settings.AutoForceJoinTime = ' .. game.Settings.AutoForceJoinTime);
	print2(addNewOrder, 'game.Settings.DirectBootTime = ' .. game.Settings.DirectBootTime);
	print2(addNewOrder, 'game.Settings.ForceJoinTime = ' .. game.Settings.ForceJoinTime);
	print2(addNewOrder, 'game.Settings.InitialBank = ' .. game.Settings.InitialBank);
	-- print2(addNewOrder, 'game.Settings.MinimumBootTime = ' .. game.Settings.MinimumBootTime);
	-- print2(addNewOrder, 'game.Settings.VoteBootTime = ' .. game.Settings.VoteBootTime);

	for playerId, player in pairs(game.ServerGame.Game.PlayingPlayers) do
		print2(addNewOrder, 'playerId = ' .. playerId);
		print2(addNewOrder, 'player.LastGameSpeed = ' .. player.LastGameSpeed);
	end
end

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if order.PlayerID == WL.PlayerID.Neutral then
		return;
	end

	print2(addNewOrder, 'result.proxyType = ' .. result.proxyType);

	if result.proxyType == 'GameOrderBossEventResult' then
		print2(addNewOrder, 'result =');
		print2(addNewOrder, p(result));
	end

	print2(addNewOrder, 'order.PlayerID = ' .. tostring(order.PlayerID));

	if order.proxyType == 'GameOrderCustom' then
		skipThisOrder(WL.ModOrderControl.Skip);
		addNewOrder(WL.GameOrderEvent.Create(order.PlayerID, 'bought bosses 1 to 4', nil, makeTerrMods(game, order.PlayerID)))
	end
end

function makeTerrMods(game, playerId)
	local tId = nil;

	for terrId, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terr.OwnerPlayerID == playerId then
			tId = terrId;
			break;
		end
	end

	-- print('playerId = '.. tostring(playerId));
	-- print('tId = ' .. tostring(tId));

	if not tId then
		return;
	end

	local terr = game.Map.Territories[tId];
	-- print('terr.Name = ' .. terr.Name);
	local terrMod = WL.TerritoryModification.Create(tId);
	terrMod.AddSpecialUnits = {};

	local i = 1;
	local stageForBoss3 = 1;

	while i < 5 do
		-- print('i = '.. i);
		local boss = WL['Boss' .. i].Create(playerId, stageForBoss3);
		table.insert(terrMod.AddSpecialUnits, boss);
		i = i + 1;
	end

	return {terrMod};
end