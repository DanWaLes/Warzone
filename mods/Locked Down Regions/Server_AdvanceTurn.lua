require('tblprint');
require('_util');
require('version');

local canRun;

function Server_AdvanceTurn_Start(game, addNewOrder)
	local host = game.Settings.StartedBy;

	if not host then
		return;
	end

	if not game.Game.Players[host] then
		return;
	end

	canRun = serverCanRunMod(game);

	if not canRun then
		return;
	end

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
		publicGD.lockedDownRegions[bonusId] = turnNo;
	end

	publicGD.newLockedDownRegions = {};
	Mod.PublicGameData = publicGD;
end

function Server_AdvanceTurn_Order(Game, order, result, skipThisOrder, addNewOrder)
	game = Game;

	local host = game.Settings.StartedBy;

	if not host then
		return;
	end

	if not game.Game.Players[host] then
		return;
	end

	if not canRun then
		return;
	end

	local isAttackTransfer = order.proxyType == 'GameOrderAttackTransfer';
	local isAirlift = order.proxyType == 'GameOrderPlayCardAirlift';

	if not (isAttackTransfer or isAirlift) then
		return;
	end

	local movementType = 'attack/transfer';
	local fromKey = 'From';
	local toKey = 'To';

	if isAirlift then
		movementType = 'airlift';
		fromKey = 'FromTerritoryID';
		toKey = 'ToTerritoryID';
	end

	local from = order[fromKey];
	local fromTerr = game.Map.Territories[from];
	local fromInLockedDownRegion = territoryInLockedDownRegion(fromTerr.ID);

	local to = order[toKey];
	local toTerr = game.Map.Territories[to];
	local toInLockedDownRegion = territoryInLockedDownRegion(toTerr.ID);

	if fromInLockedDownRegion == toInLockedDownRegion then
		return;
	end

	local fromIsActiveLockdown = fromInLockedDownRegion and (Mod.PublicGameData.lockedDownRegions[fromInLockedDownRegion] <= game.ServerGame.Game.TurnNumber);
	local toIsActiveLockdown = toInLockedDownRegion and (Mod.PublicGameData.lockedDownRegions[toInLockedDownRegion] <= game.ServerGame.Game.TurnNumber);
	local bothInActiveLockdown = fromIsActiveLockdown and toIsActiveLockdown;

	if not (fromIsActiveLockdown or toIsActiveLockdown) then
		return;
	end

	skipThisOrder(WL.ModOrderControl.SkipAndSupressSkippedMessage);

	local msg = 'Skipped ' .. movementType .. ' to ' .. toTerr.Name .. ' from ' .. fromTerr.Name .. ' because it goes into or out of ';

	if fromIsActiveLockdown then
		local affectedBonus = game.Map.Bonuses[fromInLockedDownRegion];
		local bonusValue = game.Settings.OverriddenBonuses[affectedBonus.ID] or affectedBonus.Amount;

		msg = msg .. affectedBonus.Name .. ' [' .. bonusValue .. '] ';
	end

	if bothInActiveLockdown then
		msg = msg .. 'and ';
	end

	if toIsActiveLockdown then
		local affectedBonus = game.Map.Bonuses[toInLockedDownRegion];
		local bonusValue = game.Settings.OverriddenBonuses[affectedBonus.ID] or affectedBonus.Amount;

		msg = msg .. affectedBonus.Name .. ' [' .. bonusValue .. '] ';
	end

	msg = msg .. 'which ' .. (bothInActiveLockdown and 'are' or 'is') .. ' locked down until end of turn' .. (bothInActiveLockdown and 's' or '');

	if fromIsActiveLockdown then
		msg = msg .. ' ' .. Mod.PublicGameData.lockedDownRegions[fromInLockedDownRegion];
	end

	if bothInActiveLockdown then
		msg = msg .. ' and';
	end

	if toIsActiveLockdown then
		msg = msg .. ' ' .. Mod.PublicGameData.lockedDownRegions[toInLockedDownRegion];
	end

	local playerId = WL.PlayerID.Neutral;-- neutral so that skipped orders cant be used as delays
	local affectedTerr = fromIsActiveLockdown and fromTerr or toTerr;-- should only be from or to. if both use from
	local event = WL.GameOrderEvent.Create(playerId, msg, {}, {WL.TerritoryModification.Create(affectedTerr.ID)});

	event.JumpToActionSpotOpt = WL.RectangleVM.Create(affectedTerr.MiddlePointX , affectedTerr.MiddlePointY, affectedTerr.MiddlePointX, affectedTerr.MiddlePointY);
	addNewOrder(event);
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