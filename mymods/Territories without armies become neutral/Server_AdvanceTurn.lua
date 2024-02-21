require 'util';
require 'version';

require 'terrHasNoArmies';

local payloadPrefix = 'TWABN_TerrsChanged=';

function Server_AdvanceTurn_Order(game, order, result, skipThisOrder, addNewOrder)
	if not Mod.PublicGameData.modCanDoChanges then
		return;
	end

	local isSPAndCantRunMod = game.Settings.SinglePlayer and not canRunMod();

	if isSPAndCantRunMod then
		return;
	end

	if not Mod.PublicGameData.checkedAllTerritoriesForHavingNoArmies then
		if (not Mod.PublicGameData.initialIsSPAndCantRunMod) or (Mod.PublicGameData.initialIsSPAndCantRunMod ~= isSPAndCantRunMod) then
			-- another mod may have have executed after this one in Server_StartGame giving player territories with no armies
			-- or used to have old app then updated

			checkAllTerritoriesForHavingNoArmies(game, addNewOrder);

			local publicGD = Mod.PublicGameData;
			publicGD.checkedAllTerritoriesForHavingNoArmies = true;
			Mod.PublicGameData = publicGD;
		end
	end

	if order.proxyType == 'GameOrderCustom' then
		if not string.find(order.Payload, '^' .. payloadPrefix) then
			return;
		end

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);
		processTerrsAffectedOrder(game, order, addNewOrder);
	elseif order.proxyType == 'GameOrderAttackTransfer' then
		makeTerrsAffectedOrder(addNewOrder, order.From .. ',' .. order.To .. ',');
	elseif order.proxyType == 'GameOrderPlayCardAirlift' then
		makeTerrsAffectedOrder(addNewOrder, order.FromTerritoryID .. ',' .. ToTerritoryID .. ',');
	elseif order.proxyType == 'GameOrderPlayCardBomb' then
		makeTerrsAffectedOrder(addNewOrder, order.TargetTerritoryID .. ',');
	elseif order.proxyType == 'GameOrderBossEvent' then
		makeTerrsAffectedOrder(addNewOrder, '', order.ModifyTerritories);
	elseif order.proxyType == 'GameOrderEvent' then
		makeTerrsAffectedOrder(addNewOrder, '', order.TerritoryModifications);
	end
end

function checkAllTerritoriesForHavingNoArmies(game, addNewOrder)
	-- print('in checkAllTerritoriesForHavingNoArmies');

	local terrsAffectedStr = '';

	for _, terr in pairs(game.ServerGame.LatestTurnStanding.Territories) do
		if terrHasNoArmies(terr) then
			terrsAffectedStr = terrsAffectedStr .. terr.ID .. ',';
		end
	end

	if #terrsAffectedStr > 0 then
		makeTerrsAffectedOrder(addNewOrder, terrsAffectedStr, nil, true);
	end
end

function makeTerrsAffectedOrder(addNewOrder, terrsAffectedStr, terrMods, allowTheOrderToBeAddedIfThisOrderSkipped)
	if terrMods then
		terrsAffectedStr = '';

		for _, terrMod in pairs(terrMods) do
			terrsAffectedStr = terrsAffectedStr .. terrMod.TerritoryID .. ',';
		end
	end

	local param2 = true;

	if allowTheOrderToBeAddedIfThisOrderSkipped then
		param2 = nil;
	end

	addNewOrder(WL.GameOrderCustom.Create(Mod.PublicGameData.playerForGameOrderCustoms, '', payloadPrefix .. terrsAffectedStr), param2);
end

function processTerrsAffectedOrder(game, order, addNewOrder)
	-- print('order.Payload = ' .. order.Payload);

	local i = #payloadPrefix + 1;
	local terrId = '';
	local terrMods = {};

	while i < #order.Payload + 1 do
		local c = string.sub(order.Payload, i, i);
		-- print('c = ' .. c);

		if c == ',' then
			-- print('terrId = ' .. terrId);

			local terr = game.ServerGame.LatestTurnStanding.Territories[tonumber(terrId)];

			if terrHasNoArmies(terr) then
				local terrMod = WL.TerritoryModification.Create(terr.ID);
				terrMod.SetOwnerOpt = WL.PlayerID.Neutral;

				table.insert(terrMods, terrMod);
			end

			terrId = '';
		else
			terrId = terrId .. c;
		end

		i = i + 1;
	end

	if #terrMods < 1 then
		return;
	end

	local msg = '';
	local terrDetails = game.Map.Territories[terrMods[1].TerritoryID];

	if #terrMods == 1 then
		msg = terrDetails.Name;
	else
		msg = 'Territories';
	end

	msg = msg .. ' had no armies and became neutral';

	local order = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg, {}, terrMods);
	order.JumpToActionSpotOpt = WL.RectangleVM.Create(terrDetails.MiddlePointX, terrDetails.MiddlePointY, terrDetails.MiddlePointX, terrDetails.MiddlePointY);
	addNewOrder(order);
end