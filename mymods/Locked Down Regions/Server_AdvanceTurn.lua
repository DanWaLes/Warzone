require '_util';

function Server_AdvanceTurn_Start(game, addNewOrder)
	local host = game.Settings.StartedBy;
	local gameTurnNo = game.ServerGame.Game.TurnNumber;
	local publicGD = Mod.PublicGameData;

	for bonusId, turnNo in pairs(publicGD.lockedDownRegions) do
		if turnNo < gameTurnNo then
			local bonus = game.Map.Bonuses[bonusId];
			local bonusValue = game.Settings.OverriddenBonuses[bonusId] or bonus.Amount;
			local msg = 'Lockdown in ' .. bonus.Name .. ' [' .. bonusValue .. '] ended';

			addNewOrder(WL.GameOrderEvent.Create(host, msg, nil));
			publicGD.lockedDownRegions[bonusId] = nil;
		end
	end

	for bonusId, turnNo in pairs(publicGD.newLockedDownRegions) do
		local bonus = game.Map.Bonuses[bonusId];
		local bonusValue = game.Settings.OverriddenBonuses[bonusId] or bonus.Amount;
		local msg = 'Lockdown in ' .. bonus.Name .. ' [' .. bonusValue .. '] started, ends at end of turn ' .. turnNo;

		addNewOrder(WL.GameOrderEvent.Create(host, msg, nil));
	end

	publicGD.newLockedDownRegions = {};
	Mod.PublicGameData = publicGD;
end

function Server_AdvanceTurn_Order(Game, order, result, skipThisOrder, addNewOrder)
	game = Game;

	local isAttackTransfer = order.proxyType == 'GameOrderAttackTransfer';
	local isAirlift = order.proxyType == 'GameOrderPlayCardAirlift';

	if isAttackTransfer or isAirlift then
		local movementType = isAttackTransfer and 'attack/transfer' or 'airlift';

		local from = order.From or order.FromTerritoryID;
		local fromTerr = game.Map.Territories[from];
		local fromInLockedDownRegion = territoryInLockedDownRegion(fromTerr.ID);

		local to = order.To or ToTerritoryID;
		local toTerr = game.Map.Territories[to];
		local toInLockedDownRegion = territoryInLockedDownRegion(toTerr.ID);

		if (fromInLockedDownRegion and toInLockedDownRegion) or (not fromInLockedDownRegion and not toInLockedDownRegion) then
			return;
		end

		local affectedBonus = game.Map.Bonuses[(fromInLockedDownRegion and fromInLockedDownRegion or toInLockedDownRegion)];
		local turnNo = Mod.PublicGameData.lockedDownRegions[affectedBonus.ID];

		if game.ServerGame.Game.TurnNumber > turnNo then
			return;
		end

		skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

		local msg = 'Skipped ' .. movementType .. ' to ' .. toTerr.Name .. ' from ' .. fromTerr.Name;
		msg = msg .. ' because the ' .. movementType .. ' goes into or out of ' .. affectedBonus.Name .. ' which is locked down until end of turn ' .. turnNo;

		local affectedTerr = fromInLockedDownRegion and fromTerr or toTerr;
		local event = WL.GameOrderEvent.Create(WL.PlayerID.Neutral, msg, {}, {WL.TerritoryModification.Create(affectedTerr.ID)});
		event.JumpToActionSpotOpt = WL.RectangleVM.Create(affectedTerr.MiddlePointX , affectedTerr.MiddlePointY, affectedTerr.MiddlePointX, affectedTerr.MiddlePointY);

		addNewOrder(event);
	end
end

function territoryInBonus(terrId, bonusId)
	local terr = game.Map.Territories[terrId];

	for _, terrBonusId in pairs(terr.PartOfBonuses) do
		if terrBonusId == bonusId then
			return bonusId;
		end
	end

	return nil;
end

function territoryInLockedDownRegion(terrId)
	local ret = nil;

	for bonusId in pairs(Mod.PublicGameData.lockedDownRegions) do
		ret = territoryInBonus(terrId, bonusId);

		if ret then
			break;
		end
	end

	return ret;
end